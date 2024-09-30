import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKUser
import KakaoSDKAuth

struct SignIn: View {
    @EnvironmentObject private var viewModel: SignInViewModel
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
                    
                    //                    NavigationLink(destination: EmailLoginView(viewModel: viewModel)) {
                    //                        Image("Email Login")
                    //                    }
                }
                
                Spacer()
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
            }
            .navigationDestination(isPresented: $showNextView)
            {
                Name()
            }
            
            .onChange(of: viewModel.signState) { newState in
                if newState == .signIn {
                    showNextView = true
                }
            }
        }
        .tint(.black)
    }
}



struct EmailLoginView: View {
    @ObservedObject var viewModel: SignInViewModel
    
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
        SignIn()
            .environmentObject(SignInViewModel())
        
    }
}


