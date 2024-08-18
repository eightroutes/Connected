import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class ProfileDetailViewModel: ObservableObject {
    private var imageCounts = 6
    @Published var userImages: [UIImage?] = []
    @Published var profileImage: UIImage?
    @Published var userName: String = "이름"
    @Published var userBirth: String = "Loading..."
    @Published var userAge: Int?
    @Published var userGender: String = "남"
    @Published var userMBTI: String = "INTP"
    @Published var userMusic: [String] = ["POP", "Synthwave"]
    @Published var userMovie: [String] = ["스릴러","SF"]
    @Published var userInterests: [String] = ["헬스", "책", "수영", "PC방", "노래방", "사업", "클럽", "활동적인 라이프스타일"]
    
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    
    init() {
        self.userImages = Array(repeating: nil, count: imageCounts)
    }
    
    func fetchUserProfile(for userId: String) {
//        guard let userId = Auth.auth().currentUser?.uid else { return }
        
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
                    self.userAge = self.calculateAge(from: birthdateString) ?? 20
                } else {
                    self.userAge = 20 // birthdateString이 없을 경우 기본값
                }
                
                if let profileImageUrl = data?["profile_image"] as? String {
                    self.downloadImage(from: profileImageUrl) { image in
                        DispatchQueue.main.async {
                            self.profileImage = image
                        }
                    }
                }
                
                
                if let imageUrls = data?["other_images"] as? [String] {
                    // userImages 배열의 크기를 other_images의 개수로 조정
                    self.userImages = Array(repeating: nil, count: imageUrls.count)
                    self.imageCounts = imageUrls.count
                    
                    for (index, url) in imageUrls.enumerated() {
                        self.downloadImage(from: url) { image in
                            DispatchQueue.main.async {
                                self.userImages[index] = image
                            }
                        }
                    }
                } else {
                    // other_images가 없는 경우 빈 배열로 초기화
                    self.userImages = []
                    self.imageCounts = 0
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    private func calculateAge(from birthdateString: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // 날짜 형식에 맞게 설정
        guard let birthdate = dateFormatter.date(from: birthdateString) else { return nil }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
        return ageComponents.year
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
}

