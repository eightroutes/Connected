import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Combine
import UIKit

class FirestoreManager: ObservableObject {
    @Published var usersLoc: [UserLocation] = []
    @Published var userProfile: UserProfile?
    @Published var users: [User] = []
    @Published var profileImage: UIImage?
    
    private var storage = Storage.storage()
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    var currentUserId: String?

    init() {
        // 필요한 초기화 작업
    }
    
    // MARK: -- Mark Users Locations
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
    
    func fetchUserLocations() {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.usersLoc = documents.compactMap { document -> UserLocation? in
                let data = document.data()
                guard let name = data["Name"] as? String,
                      let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double else {
                    return nil
                }
                
                let profileImageURL = data["profile_image"] as? String
                
                let user = UserLocation(id: document.documentID,
                                        name: name,
                                        latitude: latitude,
                                        longitude: longitude,
                                        profileImageURL: profileImageURL ?? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png")
                
                if let url = profileImageURL {
                    self.downloadImage(for: user, from: url)
                }
                
                return user
            }
        }
    }
    
    func downloadImage(for user: UserLocation, from url: String) {
        guard let index = self.usersLoc.firstIndex(where: { $0.id == user.id }) else { return }
        
        self.downloadImage(from: url) { image in
            DispatchQueue.main.async {
                self.usersLoc[index].profileImage = image
            }
        }
    }
    
//    // deinit 메서드를 통해 Firestore의 리스너를 제거합니다.
//    deinit {
//        listenerRegistration?.remove()
//    }
    
    // MARK: - Profile Detail
    func fetchUserProfile(userId: String) {
        let docRef = db.collection("users").document(userId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["Name"] as? String ?? "Unknown"
//                let creditAmount = data?["creditAmount"] as? String ?? "0"
//                
                if let profileImageUrl = data?["profile_image"] as? String {
                    self.downloadImage(from: profileImageUrl) { image in
                        DispatchQueue.main.async {

                            self.userProfile = UserProfile(name: name, profileImage: image)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
  
                        self.userProfile = UserProfile(name: name, profileImage: nil)

                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = storage.reference(forURL: url)
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
            } else {
                if let data = data {
                    let image = UIImage(data: data)
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Image Upload
    func uploadImage(_ image: UIImage, to path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 0.7) {
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

    // MARK: -- User Info
    func fetchUsers(completion: @escaping () -> Void) {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.users = documents.compactMap { doc -> User? in
                let data = doc.data()
                let id = doc.documentID
                let name = data["Name"] as? String ?? ""
                let profileImage = data["profile_image"] as? String ?? ""
                let interests = data["Interests"] as? [String] ?? []
                let selectedColor = data["Color"] as? String ?? ""
                let selectedMBTI = data["MBTI"] as? String ?? ""
                let musicGenres = data["Music"] as? [String] ?? []
                let movieGenres = data["Movie"] as? [String] ?? []
                
                return User(id: id, name: name, profileImage: profileImage, interests: interests, selectedColor: selectedColor, selectedMBTI: selectedMBTI, musicGenres: musicGenres, movieGenres: movieGenres)
            }
            
            completion()
        }
    }
    
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let user = User(
                    id: userId,
                    name: data?["Name"] as? String ?? "",
                    profileImage: data?["profile_image"] as? String ?? "",
                    interests: data?["Interests"] as? [String] ?? [],
                    selectedColor: data?["Color"] as? String ?? "",
                    selectedMBTI: data?["MBTI"] as? String ?? "",
                    musicGenres: data?["Music"] as? [String] ?? [],
                    movieGenres: data?["Movie"] as? [String] ?? []
                )
                completion(user)
            } else {
                print("Current user document does not exist")
                completion(nil)
            }
        }
    }
}







//import FirebaseFirestore
//import Combine
//import UIKit
//import FirebaseStorage
//import FirebaseAuth
//
//class FirestoreManager: ObservableObject {
//    @Published var usersLoc: [UserLocation] = []
//    @Published var users: [User] = []
//    
//    private var db = Firestore.firestore()
//    private var listenerRegistration: ListenerRegistration?
//    private let storageHelper = FirebaseStorageHelper()
//    
//    init() {
//        // 필요한 초기화 작업
//    }
//    
//    // MARK: -- Mark Users Locations
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
//    func fetchUserLocations() {
//        db.collection("users").addSnapshotListener { [weak self] (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            
//            self?.usersLoc = documents.compactMap { document -> UserLocation? in
//                let data = document.data()
//                guard let name = data["Name"] as? String,
//                      let latitude = data["latitude"] as? Double,
//                      let longitude = data["longitude"] as? Double else {
//                    return nil
//                }
//                
//                let profileImageURL = data["profile_image"] as? String
//                let user = UserLocation(id: document.documentID,
//                                        name: name,
//                                        latitude: latitude,
//                                        longitude: longitude,
//                                        profileImageURL: profileImageURL ?? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png")
//                
//                if let url = profileImageURL {
//                    self?.downloadImage(for: user, from: url)
//                }
//                
//                return user
//            }
//        }
//    }
//    
//    func downloadImage(for user: UserLocation, from url: String) {
//        storageHelper.downloadImage(from: url) { [weak self] image in
//            DispatchQueue.main.async {
//                if let index = self?.usersLoc.firstIndex(where: { $0.id == user.id }) {
//                    self?.usersLoc[index].profileImage = image
//                }
//            }
//        }
//    }
//    
//    // deinit 메서드를 통해 Firestore의 리스너를 제거합니다.
//    deinit {
//        listenerRegistration?.remove()
//    }
//
//    // 유저 목록 Fetch 로직
//    func fetchUsers(completion: @escaping () -> Void) {
//        db.collection("users").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error fetching users: \(error)")
//                return
//            }
//            
//            guard let documents = snapshot?.documents else {
//                print("No documents found")
//                return
//            }
//            
//            self.users = documents.compactMap { doc -> User? in
//                let data = doc.data()
//                let id = doc.documentID
//                let name = data["Name"] as? String ?? ""
//                let profileImage = data["profile_image"] as? String ?? ""
//                let interests = data["Interests"] as? [String] ?? []
//                let selectedColor = data["Color"] as? String ?? ""
//                let selectedMBTI = data["MBTI"] as? String ?? ""
//                let musicGenres = data["Music"] as? [String] ?? []
//                let movieGenres = data["Movie"] as? [String] ?? []
//                
//                return User
//            }
//            
//            completion()
//        }
//    }
//}
//
//
//class FirebaseStorageHelper {
//    private let storage = Storage.storage()
//    
//    func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
//        let storageRef = storage.reference(forURL: url)
//        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
//            if let error = error {
//                print("Error downloading image: \(error)")
//                completion(nil)
//            } else {
//                if let data = data {
//                    let image = UIImage(data: data)
//                    completion(image)
//                } else {
//                    completion(nil)
//                }
//            }
//        }
//    }
//}
