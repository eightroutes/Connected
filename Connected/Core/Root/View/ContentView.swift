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
    @State private var hasImages = false
    
    let db = Firestore.firestore()
    
//     테스트 시 자동 로그아웃
    init() {
        AuthService.shared.signOut()
    }
    
    var body: some View {
        if isActive {
            Group {
                if authService.userSession == nil {
                    LoginView()
                        .environmentObject(registrationViewModel)
                        .environmentObject(loginViewModel)
                } else if let currentUser = authService.currentUser {
                    if hasImages {
                        MainView(user: currentUser)
                    } else {
                        Name(user: currentUser)
                    }
                } else {
                    // 사용자 데이터 로딩 중
                    Text("Loading user data...")
                }
            }
            .onChange(of: authService.currentUser) { newCurrentUser in
                print("currentUser changed: \(String(describing: newCurrentUser))")
                if let user = newCurrentUser {
                    checkForOtherImages(userId: user.id ?? UUID().uuidString)
                }
            }
        } else {
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
                        if let currentUser = authService.currentUser {
                            checkForOtherImages(userId: currentUser.id)
                        }
                    }
                }
            }
        }
    }
    
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
