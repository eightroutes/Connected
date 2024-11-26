import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @StateObject var registrationViewModel = RegistrationViewModel()
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var userViewModel = UserViewModel()
    
    @ObservedObject var authService = AuthService.shared
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.1
    
    let db = Firestore.firestore()
    
    // 테스트 시 자동 로그아웃
    //    init() {
    //        AuthService.shared.signOut()
    //    }
    //
    
    var body: some View {
        if isActive {
            // NavigationStack -> Group으로 바꾸니 NTitle이 제대로 나옴
            Group {
                if authService.userSession == nil {
                    LoginView()
                        .tint(.black)
                        .environmentObject(registrationViewModel)
                        .environmentObject(loginViewModel)
                } else if let currentUser = authService.currentUser {
                    if let hasImages = userViewModel.hasImages {
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
                                userViewModel.startListening(userId: currentUser.id)
                            }
                    }
                }
            }
            .onChange(of: authService.currentUser) { newCurrentUser in
                if let user = newCurrentUser {
                    userViewModel.startListening(userId: user.id ?? "")
                } else {
                    userViewModel.stopListening()
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
            .tint(.black)
            
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
    
}
