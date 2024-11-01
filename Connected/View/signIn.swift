import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKUser
import KakaoSDKAuth

struct signIn: View {
    @EnvironmentObject private var viewModel: signInViewModel
    @State private var showNextView = false
    @State private var navigationPath = NavigationPath()
//    @StateObject private var profileviewModel = ProfileDetailViewModel()
    
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                        viewModel.kakaoAuthSignIn()
                    }) {
                        Image("Kakao Login")
                    }
                    
                    NavigationLink(destination: EmailLoginView(viewModel: viewModel)) {
                        Image("Email Login")
                    }
                }
                
                Spacer()
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
            }
            .navigationDestination(isPresented: $showNextView)
            {
                name()
            }
            .onAppear {
                viewModel.checkAndUpdateSignInStatus()
            }
//            .onChange(of: viewModel.isSignedIn) { newValue in
//                showNextView = newValue
//            }
            .onReceive(viewModel.$isSignedIn) { isSignedIn in
                if isSignedIn == true {
                    showNextView = true
                }
            }
        }
        .tint(.black)
    }
}
    
    class signInViewModel: ObservableObject {
        @Published var errorMessage: String?
        @Published var isSignedIn = false
//        @StateObject private var profileviewModel = ProfileDetailViewModel()
        
        
        init() {
            print("isSingedIn: \(isSignedIn)")
            self.isSignedIn = Auth.auth().currentUser != nil
        }
        
        func checkAndUpdateSignInStatus() {
            DispatchQueue.main.async { [weak self] in
                self?.isSignedIn = Auth.auth().currentUser != nil && Auth.auth().currentUser?.uid != nil
            }
        }
        // MARK: - Google SignIn Function
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
        
        // MARK: - KakaoAuth SignIn Function
        func kakaoAuthSignIn() {
            if AuthApi.hasToken() { // 발급된 토큰이 있는지
                UserApi.shared.accessTokenInfo { _, error in // 해당 토큰이 유효한지
                    if let error = error { // 에러가 발생했으면 토큰이 유효하지 않다.
                        self.openKakaoService()
                    } else { // 유효한 토큰
                        self.loadingInfoDidKakaoAuth()
                    }
                }
            } else { // 만료된 토큰
                self.openKakaoService()
            }
        }
        
        func openKakaoService() {
            if UserApi.isKakaoTalkLoginAvailable() { // 카카오톡 앱 이용 가능한지
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in // 카카오톡 앱으로 로그인
                    if let error = error { // 로그인 실패 -> 종료
                        print("Kakao Sign In Error: ", error.localizedDescription)
                        return
                    }
                    
                    _ = oauthToken // 로그인 성공
                    self.loadingInfoDidKakaoAuth() // 사용자 정보 불러와서 Firebase Auth 로그인하기
                }
            } else { // 카카오톡 앱 이용 불가능한 사람
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in // 카카오 웹으로 로그인
                    if let error = error { // 로그인 실패 -> 종료
                        print("Kakao Sign In Error: ", error.localizedDescription)
                        return
                    }
                    _ = oauthToken // 로그인 성공
                    self.loadingInfoDidKakaoAuth() // 사용자 정보 불러와서 Firebase Auth 로그인하기
                }
            }
        }
        
        func loadingInfoDidKakaoAuth() {  // 사용자 정보 불러오기
            UserApi.shared.me { kakaoUser, error in
                if let error = error {
                    print("카카오톡 사용자 정보 불러오는데 실패했습니다.")
                    
                    return
                }
                guard let email = kakaoUser?.kakaoAccount?.email else { return }
                guard let password = kakaoUser?.id else { return }
                guard let userName = kakaoUser?.kakaoAccount?.profile?.nickname else { return }
                
                self.signInWithEmail(email: email, password: String(password))
            }
        }
        func signInWithEmail(email: String, password: String) {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("Successfully signed in with Email")
                    DispatchQueue.main.async {
                        self?.isSignedIn = true
                        
                    }
                }
            }
        }
    }
    
    struct EmailLoginView: View {
        @ObservedObject var viewModel: signInViewModel
        
        @State private var email = ""
        @State private var password = ""
        
        fileprivate func Line() -> some View {
            return Rectangle()
                .frame(width: 300, height: 0.5)
        }
        
        var body: some View {
            VStack {
                HStack{
                    Text("이메일과 비밀번호를 입력하세요")
                        .frame(width: 300)
                        .font(.title)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.bottom, 20)
                
                VStack() {
                    TextField("이메일 주소 입력", text: $email)
                        .padding()
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .frame(width: 320, height: 30)
                    
                    Line()
                    
                    SecureField("비밀번호 8자리 이상 입력", text: $password)
                        .padding()
                        .autocapitalization(.none)
                        .frame(width: 320, height: 30)
                    
                    Line()
                }
                .padding(.bottom, 30)
                
                Button(action: {
                    viewModel.signInWithEmail(email: email, password: password)
                }) {
                    Text("로그인")
                        .frame(width: 250)
                        .foregroundColor(.white)
                        .padding()
                        .background(isValidEmail(email) && isValidPassword(password) ? Color.black : Color.unselectedButton)
                        .cornerRadius(30)
                }
                .disabled(!(isValidEmail(email) && isValidPassword(password)))
                
                Spacer()
            }
            //        .navigationTitle("Email Login")
            .padding()
        }
        
        private func isValidEmail(_ email: String) -> Bool {
            // 이메일 유효성 검사를 위한 간단한 정규 표현식 사용
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: email)
        }
        
        private func isValidPassword(_ password: String) -> Bool {
            // 비밀번호가 8자리 이상인지 확인
            return password.count >= 8
        }
    }
    
    
    struct signIn_Previews: PreviewProvider {
        static var previews: some View {
            signIn()
                .environmentObject(signInViewModel())
            
        }
    }
    
    
