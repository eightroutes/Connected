import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKUser
import KakaoSDKAuth

struct signIn: View {
    @StateObject private var viewModel = SignInViewModel()
    @State private var showNextView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("SplashLogo")
                    .resizable()
                    .frame(width: 190, height: 119.19)
                    .padding(.top, 200.0)
                
                Text("CONNECTED")
                    .padding(.top, 10)
                    .fontWeight(.bold)
                    .font(.title)
                
                Spacer()
                
                VStack(spacing: 10) {
                    Image("Apple Login")
                    
                    Button(action: {
                        viewModel.googleLogin()
                    }) {
                        Image("Google Login")
                    }
                    
                    Button(action: {
                        viewModel.kakaoLogin()
                    }) {
                        Image("Kakao Login")
                    }
                }
                
                Spacer()
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            
            }
            .navigationDestination(isPresented: $showNextView) {
                name()
            }
        }
        .onReceive(viewModel.$isSignedIn) { isSignedIn in
            if isSignedIn {
                showNextView = true
            }
        }
        .accentColor(.black)
    }
}

class SignInViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isSignedIn = false
    
    func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard error == nil else {
                self?.errorMessage = error?.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.errorMessage = "Failed to get user information"
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("Successfully signed in with Google")
                    DispatchQueue.main.async {
                        self?.isSignedIn = true
                    }
                }
            }
        }
    }
    
    func kakaoLogin() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let error = error {
                    print(error)
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("loginWithKakaoTalk() success.")
                    self?.fetchKakaoUserInfo()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] (oauthToken, error) in
                if let error = error {
                    print(error)
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("loginWithKakaoAccount() success.")
                    self?.fetchKakaoUserInfo()
                }
            }
        }
    }

    private func fetchKakaoUserInfo() {
        UserApi.shared.me { [weak self] (user, error) in
            if let error = error {
                print(error)
                self?.errorMessage = error.localizedDescription
            } else {
                print("me() success.")
                // 로그인 성공 후 사용자 정보 처리
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                }
            }
        }
    }
}


struct signIn_Previews: PreviewProvider {
    static var previews: some View {
        signIn()
    }
}
