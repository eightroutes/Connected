import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class GroupViewModel: ObservableObject {
    func createGroup(name: String, description: String, theme: String, location: String, image: UIImage?, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        let groupId = UUID().uuidString
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 인증되지 않았습니다."]))
            return
        }
        
        let members = [currentUserId]
        
        
        var groupData: [String: Any] = [
            "id": groupId,
            "name": name,
            "description": description,
            "location": location,
            "memberCounts": members.count,
            "createdAt": FieldValue.serverTimestamp(),
            "theme": theme,
            "members": members
        ]
        
        if let image = image {
            uploadGroupImage(image, groupId: groupId) { result in
                switch result {
                case .success(let imageUrl):
                    groupData["mainImageUrl"] = imageUrl
                    db.collection("groups").document(groupId).setData(groupData) { error in
                        if let error = error {
                            print("Error creating group: \(error.localizedDescription)")
                            completion(false, error)
                        } else {
                            print("Group created successfully")
                            completion(true, nil)
                        }
                    }
                case .failure(let error):
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(false, error)
                }
            }
        } else {
            db.collection("groups").document(groupId).setData(groupData) { error in
                if let error = error {
                    print("Error creating group: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("Group created successfully")
                    completion(true, nil)
                }
            }
        }
    }
    
    private func uploadGroupImage(_ image: UIImage, groupId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("groupImages/\(groupId).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if let imageUrl = url?.absoluteString {
                        completion(.success(imageUrl))
                    } else {
                        completion(.failure(NSError(domain: "Image URL is nil", code: -1, userInfo: nil)))
                    }
                }
            }
        } else {
            completion(.failure(NSError(domain: "Image data is nil", code: -1, userInfo: nil)))
        }
    }
}
