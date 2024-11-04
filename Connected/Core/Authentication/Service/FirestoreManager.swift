import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Combine
import UIKit

class FirestoreManager: ObservableObject {
    @Published var usersLoc: [User] = [] // Users list with locations
    @Published var users: [User] = []    // General list of users
    @Published var currentUser: User?    // Single user profile
    
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
            DispatchQueue.main.async {
                completion(nil)
            }
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
                        self.currentUser = user
                        completion(user)
                    }
                } catch {
                    print("Error decoding user: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
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
        // Remove existing listener if it exists
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            // Map documents to User objects and assign to usersLoc
            let newUsersLoc = documents.compactMap { document -> User? in
                let data = document.data()
                guard
                    let name = data["Name"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double
                else {
                    return nil
                }
                
                return User(
                    id: document.documentID,
                    name: name,
                    latitude: latitude,
                    longitude: longitude
                )
            }
            
            DispatchQueue.main.async {
                self.usersLoc = newUsersLoc
            }
        }
        
        
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
}
