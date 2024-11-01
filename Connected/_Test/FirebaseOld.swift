//import FirebaseFirestore
//import FirebaseStorage
//import FirebaseAuth
//import Combine
//import UIKit
//
//class FirestoreManager: ObservableObject {
//    @Published var usersLoc: [User] = [] // Users list with locations
//    @Published var user: User?    // Single user profile
//    @Published var users: [User] = []    // General list of users
//    @Published var profileImage: UIImage?
//
//    private var storage = Storage.storage()
//    private var db = Firestore.firestore()
//    private var listenerRegistration: ListenerRegistration?
//    
//    var currentUserId: String?
//
//    init() {
//        // Initialization if needed
//    }
//    
//    // MARK: -- Update User Location
//    func updateUserLocation(userId: String, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
//        db.collection("users").document(userId).updateData([
//            "latitude": latitude,
//            "longitude": longitude
//        ]) { error in
//            if let error = error {
//                print("Error updating user location: \(error)")
//                completion(false)
//            } else {
//                completion(true)
//            }
//        }
//    }
//    
//    // MARK: - Fetch User Locations
//    func fetchUserLocations() {
//        db.collection("users").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents found")
//                return
//            }
//            
//            self.usersLoc = documents.compactMap { document -> User? in
//                let data = document.data()
//                guard let name = data["Name"] as? String,
//                      let latitude = data["latitude"] as? Double,
//                      let longitude = data["longitude"] as? Double,
//                      let gender = data["Gender"] as? String,
//                      let profileImageURL = data["profile_image"] as? String,
//                      let interests = data["Interests"] as? [String],
//                      let selectedColor = data["Color"] as? String,
//                      let selectedMBTI = data["MBTI"] as? String,
//                      let musics = data["Music"] as? [String],
//                      let movies = data["Movie"] as? [String]
//                else {
//                    return nil
//                }
//                
//                let user = User(
//                    id: document.documentID,
//                    name: name,
//                    gender: gender,
//                    interests: interests,
//                    selectedColor: selectedColor,
//                    selectedMBTI: selectedMBTI,
//                    musicGenres: musics,
//                    movieGenres: movies,
//                    profileImageUrl: profileImageURL,
//                    latitude: latitude,
//                    longitude: longitude,
//                    email: ""
//                )
//                
//                return user
//            }
//        }
//    }
//
//    // MARK: - Profile Detail
//    func fetchUserProfile(userId: String) async throws {
//        // Firestore에서 userId로 문서를 가져옴
//        let snapshot = try await db.collection("users").document(userId).getDocument()
//
//        // 문서가 존재하는지 확인
//        guard let data = snapshot.data() else {
//            print("Document does not exist for the user profile")
//            return
//        }
//        
//        // 문서에서 각 필드를 가져옴
//        guard let name = data["Name"] as? String,
//              let gender = data["Gender"] as? String,
//              let profileImageURL = data["profile_image"] as? String,
//              let interests = data["Interests"] as? [String],
//              let selectedColor = data["Color"] as? String,
//              let selectedMBTI = data["MBTI"] as? String,
//              let musics = data["Music"] as? [String],
//              let movies = data["Movie"] as? [String],
//              let latitude = data["latitude"] as? Double,
//              let longitude = data["longitude"] as? Double
//        else {
//            print("Missing data in user profile.")
//            return
//        }
//    
//        // 메인 스레드에서 사용자 데이터 업데이트
//        DispatchQueue.main.async {
//            self.user = self.user
//        }
//    }
//
//    // MARK: - Image Upload
//    func uploadImage(_ image: UIImage, to path: String, completion: @escaping (Result<URL, Error>) -> Void) {
//        if let imageData = image.jpegData(compressionQuality: 0.5) {
//            let storageRef = storage.reference().child(path)
//            
//            storageRef.putData(imageData, metadata: nil) { metadata, error in
//                if let error = error {
//                    print("Error uploading image: \(error)")
//                    completion(.failure(error))
//                } else {
//                    storageRef.downloadURL { url, error in
//                        if let error = error {
//                            print("Error getting download URL: \(error)")
//                            completion(.failure(error))
//                        } else if let url = url {
//                            print("Image uploaded successfully, download URL: \(url)")
//                            completion(.success(url))
//                        }
//                    }
//                }
//            }
//        } else {
//            print("Failed to compress image.")
//            completion(.failure(NSError(domain: "ImageCompressionError", code: 1, userInfo: nil)))
//        }
//    }
//
//    // MARK: - Fetch Users
////    func fetchUsers(completion: @escaping () -> Void) {
////        let snapshot = try await db.collection("users").document(userId).getDocument()
////
////        db.collection("users").getDocuments { snapshot, error in
////            if let error = error {
////                print("Error fetching users: \(error)")
////                return
////            }
////
////            guard let documents = snapshot?.documents else {
////                print("No documents found")
////                return
////            }
////
////            self.users = documents.compactMap { doc -> User? in
////                let data = doc.data()
////                guard let name = data["Name"] as? String,
////                      let profileImage = data["profile_image"] as? String,
////                      let interests = data["Interests"] as? [String],
////                      let selectedColor = data["Color"] as? String,
////                      let selectedMBTI = data["MBTI"] as? String,
////                      let musicGenres = data["Music"] as? [String],
////                      let movieGenres = data["Movie"] as? [String],
////                      let gender = data["Gender"] as? String,
////                      let latitude = data["latitude"] as? Double,
////                      let longitude = data["longitude"] as? Double
////                else {
////                    return nil
////                }
////
////                return User(id: doc.documentID, name: name, gender: gender, interests: interests, selectedColor: selectedColor, selectedMBTI: selectedMBTI, musicGenres: musicGenres, movieGenres: movieGenres, profileImageURL: profileImage, profileImage: nil, latitude: latitude, longitude: longitude)
////            }
////            completion()
////        }
////    }
//}
