import SwiftUI
import FirebaseAuth
import FirebaseCore

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @State private var showNextView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack {
                    Image("SplashLogo")
                        .resizable()
                        .frame(width: 190, height: 119.19)
                        .padding(.top, 200.0)
                    
                    Text("CONNECTED")
                        .padding(.top, 10)
                        .fontWeight(.bold)
                        .font(.title)
                    
                }
                Spacer()
                    .frame(height: 30)
                
                VStack {
                    TextField("이메일 주소 입력", text: $viewModel.email)
                        .autocapitalization(.none)
                        .modifier(TextFieldModifier())
                    
                    SecureField("비밀번호 입력", text: $viewModel.password)
                        .modifier(TextFieldModifier())
                }
                
                
                VStack {
                    Button {
                        Task {
                            do {
                                try await viewModel.signIn()
                            }
                            catch {
                                
                            }
                        }
                    } label: {
                        Text("로그인")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 250, height: 44)
                            .background(Color.brand)
                            .cornerRadius(8)
                    }
                    .padding(.vertical)
                    
                    // 오류메시지
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 5)
                            .onAppear {
                                // 3초 후 errorMessage를 자동으로 사라지게 함
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    viewModel.errorMessage = nil
                                }
                            }
                    }
                }
                
                
                VStack {
                    HStack {
                        Rectangle()
                            .frame(width: (UIScreen.main.bounds.width / 2) - 80, height: 0.5)
                        Text("OR")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Rectangle()
                            .frame(width: (UIScreen.main.bounds.width / 2) - 80, height: 0.5)
                    }
                    .foregroundStyle(.gray)
                }
                
                VStack {
                    Button {
                        Task {
                            do {
                                try await AuthService.shared.googleSignIn()
                            } catch {
                                print("DEBUG: Google Sign-In failed with error \(error.localizedDescription)")
                            }
                        }
                    } label: {
                        Image("Google Login")
                    }
                }
                
                Spacer()
                
                // 이메일 회원가입
                NavigationLink {
                    EmailRegisterView()
                        .tint(.black)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                    .font(.footnote)
                }
                .padding(.vertical, 16)
            }
        }//NavigationStack
        .tint(.black)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    LoginView()
}
