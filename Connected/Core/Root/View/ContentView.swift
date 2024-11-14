import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @StateObject var registrationViewModel = RegistrationViewModel()
    @StateObject var loginViewModel = LoginViewModel()
    
    @ObservedObject var authService = AuthService.shared
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.1
    @State private var hasImages: Bool? = nil

    let db = Firestore.firestore()
    
//     테스트 시 자동 로그아웃
//    init() {
//        AuthService.shared.signOut()
//    }
    
    
    var body: some View {
        if isActive {
            Group {
                if authService.userSession == nil {
                    LoginView()
                        .environmentObject(registrationViewModel)
                        .environmentObject(loginViewModel)
                } else if let currentUser = authService.currentUser {
                    if let hasImages = hasImages {
                        if hasImages {
                            MainView(user: currentUser)
                        } else {
                            Name(user: currentUser)
                        }
                    } else {
                        // 사용자 데이터 로딩 중
                        Image(systemName: "slowmo")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .symbolEffect(.variableColor)
                            .onAppear {
                                loadUserData()
                            }
                    }
                }
            }
            .onAppear {
                if hasImages == nil, let currentUser = authService.currentUser {
                    checkForOtherImages(userId: currentUser.id ?? "")
                }
            }
            .onChange(of: authService.currentUser) { newCurrentUser in
                if let user = newCurrentUser {
                    checkForOtherImages(userId: user.id ?? "")
                }
            }
            
        }else {
            VStack {
                VStack {
                    Image("SplashLogo")
                }
                .scaleEffect(size)
            }
            .tint(.black)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        self.isActive = true
//                        if let currentUser = authService.currentUser {
//                            checkForOtherImages(userId: currentUser.id)
//                        }
                        if authService.userSession != nil && authService.currentUser == nil {
                            loadUserData()
                        }
                    }
                }
            }
        }
    }
    
    private func loadUserData() {
        Task {
            do {
                try await authService.loadUserData()
            } catch {
                print("Error loading user data: \(error)")
                // Handle error appropriately
            }
        }
    }
    
    // 데이터 로드중에 hasImages가 일시적으로 false로 설정될 수 있기에 Name뷰로 넘어가는 오류 =>
    // hasImages의 상태를 세 가지로 구분합니다:
    //    nil: 아직 데이터를 로드하지 않은 상태
    //    true: 이미지가 있음
    //    false: 이미지가 없음
    private func checkForOtherImages(userId: String) {
        let document = db.collection("users").document(userId)
        document.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let otherImages = data?["other_images"] as? [String], !otherImages.isEmpty {
                    DispatchQueue.main.async {
                        self.hasImages = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hasImages = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.hasImages = false
                }
            }
        }
    }
}
