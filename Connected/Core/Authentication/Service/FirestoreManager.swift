import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Combine
import UIKit

class FirestoreManager: ObservableObject {
    @Published var usersLoc: [User] = [] // Users list with locations
    @Published var user: User?    // Single user profile
    @Published var users: [User] = []    // General list of users
    @Published var profileImage: UIImage?
    
    private var storage = Storage.storage()
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    var currentUserId: String?
    
    init() {
        // Initialization if needed
        
    }
    
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                completion(nil)
                return
            }
            
            db.collection("users").document(currentUserId).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching current user: \(error)")
                    completion(nil)
                    return
                }
                
                if let document = document, let data = document.data() {
                    do {
                        let user = try Firestore.Decoder().decode(User.self, from: data)
                        DispatchQueue.main.async {
                            self.user = user
                        }
                        completion(user)
                    } catch {
                        print("Error decoding user: \(error)")
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    
    
    func fetchUsers(completion: @escaping () -> Void) {
            db.collection("users").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching users: \(error)")
                    completion()
                    return
                }
                
                self.users = querySnapshot?.documents.compactMap { document -> User? in
                    let data = document.data()
                    do {
                        var user = try Firestore.Decoder().decode(User.self, from: data)
                        user.id = document.documentID
                        return user
                    } catch {
                        print("Error decoding user: \(error)")
                        return nil
                    }
                } ?? []
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    
    
    // MARK: -- Update User Location
    func updateUserLocation(userId: String, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userId).updateData([
            "latitude": latitude,
            "longitude": longitude
        ]) { error in
            if let error = error {
                print("Error updating user location: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - Fetch User Locations
    func fetchUserLocations() {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.usersLoc = documents.compactMap { document -> User? in
                let data = document.data()
                print("Document ID: \(document.documentID), Data: \(data)")

                guard let name = data["Name"] as? String,
                      let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double
                        //                      let gender = data["Gender"] as? String,
                        //                      let profileImageURL = data["profile_image"] as? String,
                        //                      let interests = data["Interests"] as? [String],
                        //                      let selectedColor = data["Color"] as? String,
                        //                      let selectedMBTI = data["MBTI"] as? String,
                        //                      let musics = data["Music"] as? [String],
                        //                      let movies = data["Movie"] as? [String]
                else {
                    return nil
                }
                
                let user = User(
                    id: document.documentID,
                    name: name,
                    //                    gender: gender,
                    //                    interests: interests,
                    //                    selectedColor: selectedColor,
                    //                    selectedMBTI: selectedMBTI,
                    //                    musicGenres: musics,
                    //                    movieGenres: movies,
                    //                    profileImageUrl: profileImageURL,
                    latitude: latitude,
                    longitude: longitude
                )
                print("Number of users retrieved: \(self.usersLoc.count)")

                
                return user
            }
        }
    }
    
    // MARK: - Profile Detail
//    func fetchUserProfile(userId: String, completion: @escaping (User?) -> Void) {
//        let docRef = db.collection("users").document(userId)
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let data = document.data()
//                // 필요한 데이터를 사용해 User 객체 생성
//                let user = User(
//                    id: userId,
//                    name: data?["Name"] as? String ?? "Unknown",
//                    gender: data?["Gender"] as? String ?? "Unknown",
//                    interests: data?["Interests"] as? [String] ?? [],
//                    selectedColor: data?["Color"] as? String,
//                    selectedMBTI: data?["MBTI"] as? String,
//                    musicGenres: data?["Music"] as? [String] ?? [],
//                    movieGenres: data?["Movie"] as? [String] ?? [],
//                    profileImageUrl: data?["profile_image"] as? String,
//                    otherImagesUrl: data?["other_images"] as? [String] ?? [],
//                    latitude: data?["latitude"] as? Double,
//                    longitude: data?["longitude"] as? Double,
//                    email: data?["email"] as? String ?? ""
//                )
//                completion(user)
//                
//                
//            } else {
//                print("Document does not exist")
//                completion(nil)
//            }
//        }
//    }

    
    // MARK: - Image Upload
    func uploadImage(_ image: UIImage, to path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            let storageRef = storage.reference().child(path)
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error)")
                    completion(.failure(error))
                } else {
                    storageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error getting download URL: \(error)")
                            completion(.failure(error))
                        } else if let url = url {
                            print("Image uploaded successfully, download URL: \(url)")
                            completion(.success(url))
                        }
                    }
                }
            }
        } else {
            print("Failed to compress image.")
            completion(.failure(NSError(domain: "ImageCompressionError", code: 1, userInfo: nil)))
        }
    }
    
}
