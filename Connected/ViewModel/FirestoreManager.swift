import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Combine

class FirestoreManager: ObservableObject {
    @Published var usersLoc: [UserLocation] = []
    @Published var userProfile: UserProfile?
    @Published var users: [User] = []
    
    private var storage = Storage.storage()
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        
    }
    
    // MARK: -- Mark Users Locations
    func updateUserLocation(latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            completion(false)
            return
        }
        
        let userRef = db.collection("users").document(userId)
        userRef.updateData([
            "latitude": latitude,
            "longitude": longitude
        ]) { error in
            if let error = error {
                print("Error updating user location: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User location successfully updated")
                completion(true)
            }
        }
    }
    func fetchUserLocations() {
        listenerRegistration = db.collection("users").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching user locations: \(error.localizedDescription)")
                return
            }
            
            self.usersLoc = snapshot?.documents.compactMap { document in
                let data = document.data()
                guard let name = data["name"] as? String,
                      let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double else {
                    return nil
                }
                return UserLocation(id: document.documentID, name: name, latitude: latitude, longitude: longitude)
            } ?? []
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
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
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
                let name = data["name"] as? String ?? ""
                let profileImage = data["profileImage"] as? String ?? ""
                let interests = data["interests"] as? [String] ?? []
                let selectedColor = data["selectedColor"] as? String ?? ""
                let selectedMBTI = data["selectedMBTI"] as? String ?? ""
                let musicGenres = data["musicGenres"] as? [String] ?? []
                let movieGenres = data["movieGenres"] as? [String] ?? []
                
                return User(id: id, name: name, profileImage: profileImage, interests: interests, selectedColor: selectedColor, selectedMBTI: selectedMBTI, musicGenres: musicGenres, movieGenres: movieGenres)
            }
            
            completion()
        }
    }
    
}

struct UserLocation: Identifiable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
}


struct UserProfile {
    var name: String
    var creditAmount: String
    var profileImage: UIImage?
}
