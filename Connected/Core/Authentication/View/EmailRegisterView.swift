import SwiftUI

struct EmailRegisterView: View {
    // 뷰에서 최초로 사용하는 객체의 초기화,
    // 클래스의 인스턴스를 관리하며, 이 인스턴스가 변경될 때마다 뷰가 갱신
    @StateObject var viewModel = RegistrationViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showAlert = false
    
    fileprivate func Line() -> some View {
        return Rectangle()
            .frame(width: 300, height: 0.5)
    }
    
    var body: some View {
        
        NavigationStack {
            VStack {
                HStack {
                    Text("이메일과 비밀번호를 입력하세요")
                        .frame(width: 300)
                        .font(.title)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.bottom, 20)
                
                VStack {
                    TextField("이메일 주소 입력", text: $viewModel.email)
                        .padding()
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .frame(width: 320, height: 30)
                    
                    Line()
                    
                    SecureField("비밀번호 8자리 이상 입력", text: $viewModel.password)
                        .padding()
                        .autocapitalization(.none)
                        .frame(width: 320, height: 30)
                    
                    Line()
                    
                }
                .padding(.bottom, 30)
                
                Button(action: {
                    Task {
                        do {
                            try await viewModel.createUser()
                            showAlert = true
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("회원가입")
                        .frame(width: 250)
                        .foregroundColor(.white)
                        .padding()
                        .background(isValidEmail(viewModel.email) && isValidPassword(viewModel.password) ? Color.black : Color.unselectedButton)
                        .cornerRadius(30)
                }
                .disabled(!(isValidEmail(viewModel.email) && isValidPassword(viewModel.password)))
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("회원가입 완료"), message: Text("회원가입이 성공적으로 완료되었습니다."), dismissButton: .default(Text("확인")) {
                        dismiss()
                    })
                }
                
                
                Spacer()
            }
            .padding()
        }//NavigationStack
        .tint(.black)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}

#Preview {
    EmailRegisterView()
}
