import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import Kingfisher

class ProfileDetailViewModel: ObservableObject {
    private var imageCounts = 6
    @Published var isSignedIn = false

    @Published var userImagesUrl: [String] = [] // URLs for user images
    @Published var profileImageUrl: String?
    @Published var userName: String = "이름"
    @Published var userBirth: String = "Loading..."
    @Published var userAge: Int?
    @Published var userGender: String = "남"
    @Published var userMBTI: String = "INTP"
    @Published var userMusic: [String] = ["POP", "Synthwave"]
    @Published var userMovie: [String] = ["스릴러", "SF"]
    @Published var userInterests: [String] = ["헬스", "책", "수영", "PC방", "노래방", "사업", "클럽", "활동적인 라이프스타일"]

    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    @Published var user: User?

    func fetchUserProfile(for userId: String) {
        let docRef = db.collection("users").document(userId)
        docRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["Name"] as? String ?? "Unknown"
                self.userBirth = data?["Birthday"] as? String ?? "Unknown"
                self.userGender = data?["Gender"] as? String ?? "Unknown"
                self.userMBTI = data?["MBTI"] as? String ?? "Unknown"
                self.userMusic = data?["Music"] as? [String] ?? ["Unknown"]
                self.userMovie = data?["Movie"] as? [String] ?? ["Unknown"]
                self.userInterests = data?["Interests"] as? [String] ?? ["Unknown"]

                if let birthdateString = data?["Birthday"] as? String {
                    self.userAge = self.calculateAge(from: birthdateString)
                } else {
                    self.userAge = 20 // Default value if birthdateString is not available
                }

                if let profileImageUrl = data?["profile_image"] as? String {
                    DispatchQueue.main.async {
                        self.profileImageUrl = profileImageUrl
                    }
                }

                if let imageUrls = data?["other_images"] as? [String] {
                    DispatchQueue.main.async {
                        self.userImagesUrl = imageUrls
                        self.imageCounts = imageUrls.count
                    }
                } else {
                    // Set empty array if no other images are available
                    DispatchQueue.main.async {
                        self.userImagesUrl = []
                        self.imageCounts = 0
                    }
                }

                DispatchQueue.main.async {
                    self.user = User(
                        id: userId,
                        name: self.userName,
                        gender: self.userGender,
                        interests: self.userInterests,
                        selectedColor: nil,
                        selectedMBTI: self.userMBTI,
                        musicGenres: self.userMusic,
                        movieGenres: self.userMovie,
                        profileImageUrl: self.profileImageUrl,
                        otherImagesUrl: self.userImagesUrl,
                        latitude: nil,
                        longitude: nil,
                        email: "",
                        age: self.userAge,
                        birthday: self.userBirth
                    )
                }

            } else {
                print("Document does not exist")
            }
        }
    }

    private func calculateAge(from birthdateString: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust date format accordingly
        guard let birthdate = dateFormatter.date(from: birthdateString) else { return nil }

        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
        return ageComponents.year
    }
}
