import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class ProfileDetailViewModel: ObservableObject {
    private var imageCounts = 6
    @Published var isSignedIn = false

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

//        checkUserStatus()

//        self.userImages = Array(repeating: nil, count: imageCounts)


    }


//    func checkUserStatus() {
//        if let userId = Auth.auth().currentUser?.uid {
//            isSignedIn = true
//            fetchUserProfile(for: userId)
//        } else {
//            isSignedIn = false
////            userImages = []
//        }
//    }


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
                                // 배열 범위 내에서만 값을 설정
                                if index >= 0 && index < self.userImages.count {
                                    self.userImages[index] = image
                                }
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



//import FirebaseAuth
//import Combine
//import UIKit
//import FirebaseFirestore
//
//class ProfileDetailViewModel: ObservableObject {
//    @Published var isSignedIn = false
//    @Published var userProfile: UserProfile?
//    @Published var userImages: [UIImage?] = []
//    
//    private let db = Firestore.firestore()
//    private let storageHelper = FirebaseStorageHelper()
//    
//    init() {
//        checkUserStatus()
//    }
//    
//    func checkUserStatus() {
//        if let userId = Auth.auth().currentUser?.uid {
//            isSignedIn = true
//            fetchUserProfile(for: userId)
//        } else {
//            isSignedIn = false
//        }
//    }
//    
//    func fetchUserProfile(for userId: String) {
//        let docRef = db.collection("users").document(userId)
//        docRef.getDocument { [weak self] (document, error) in
//            guard let self = self, let document = document, document.exists else {
//                print("Document does not exist")
//                return
//            }
//            
//            let data = document.data()
//            let name = data?["Name"] as? String ?? "Unknown"
//            let birth = data?["Birthday"] as? String ?? "Unknown"
//            let gender = data?["Gender"] as? String ?? "Unknown"
//            let mbti = data?["MBTI"] as? String ?? "Unknown"
//            let music = data?["Music"] as? [String] ?? ["Unknown"]
//            let movie = data?["Movie"] as? [String] ?? ["Unknown"]
//            let interests = data?["Interests"] as? [String] ?? ["Unknown"]
//            
//            let profileImageUrl = data?["profile_image"] as? String
//            self.downloadProfileImage(from: profileImageUrl)
//            
//            let userAge = self.calculateAge(from: birth) ?? 20
//            
//            // Fetch other images
//            if let imageUrls = data?["other_images"] as? [String] {
//                self.userImages = Array(repeating: nil, count: imageUrls.count)
//                for (index, url) in imageUrls.enumerated() {
//                    self.downloadImage(for: index, from: url)
//                }
//            } else {
//                self.userImages = []
//            }
//            
//            DispatchQueue.main.async {
//                self.userProfile = UserProfile(
//                    name: name,
//                    age: userAge,
//                    gender: gender,
//              
//                    mbti: mbti,
//                    music: music,
//                    movie: movie,
//                    interests: interests,
//                    profileImage: nil
//                )
//            }
//        }
//    }
//    
//    private func downloadProfileImage(from url: String?) {
//        guard let url = url else { return }
//        storageHelper.downloadImage(from: url) { [weak self] image in
//            DispatchQueue.main.async {
//                self?.userProfile?.profileImage = image
//            }
//        }
//    }
//    
//    private func downloadImage(for index: Int, from url: String) {
//        storageHelper.downloadImage(from: url) { [weak self] image in
//            DispatchQueue.main.async {
//                self?.userImages[index] = image
//            }
//        }
//    }
//    
//    private func calculateAge(from birthdateString: String) -> Int? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd" // 날짜 형식에 맞게 설정
//        guard let birthdate = dateFormatter.date(from: birthdateString) else { return nil }
//        
//        let calendar = Calendar.current
//        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
//        return ageComponents.year
//    }
//    
//}
