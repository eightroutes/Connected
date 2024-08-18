import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Combine

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
        
    }
    
    // MARK: -- Mark Users Locations
    func updateUserLocation(userId: String, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
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
    
    
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Profile Detail
    func fetchUserProfile(userId: String) {
        let docRef = db.collection("users").document(userId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["Name"] as? String ?? "Unknown"
                let creditAmount = data?["creditAmount"] as? String ?? "0"
                if let profileImageUrl = data?["profile_image"] as? String {
                    self.downloadImage(from: profileImageUrl) { image in
                        DispatchQueue.main.async {
                            self.userProfile = UserProfile(name: name, creditAmount: creditAmount, profileImage: image)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.userProfile = UserProfile(name: name, creditAmount: creditAmount, profileImage: nil)
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
    
    
    // MARK: -- User Info
    func fetchUsers(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
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
                // User 객체 생성 로직
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




