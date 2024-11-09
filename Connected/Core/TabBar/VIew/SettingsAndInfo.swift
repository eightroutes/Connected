import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct SettingsAndInfo: View {
    @State private var notificationsEnabled = true
    @State private var showLogoutAlert = false
    @State var currentUser: User
    @State private var shouldNavigateToSignIn = false
    
    
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    NavigationLink(destination: ProfileDetail(user: currentUser)) {
                        Text("내 프로필")
                            .onAppear{
                                // 현재 로그인한 사용자의 ID 가져오기
                                currentUser.id = Auth.auth().currentUser?.uid ?? ""
                            }
                    }
                    
                    Section(header: Text("친구")) {
                        NavigationLink(destination: FriendsListView()){
                            Text("친구")
                        }
                        
                    }
                    
                    Section(header: Text("알림")) {
                        Toggle("알림 설정", isOn: $notificationsEnabled)
                    }
                    
                    Section(header: Text("계정")) {
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            Text("로그아웃")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Section(header: Text("앱 정보")) {
                        Text("버전 1.0.0")
//                        Text("개인정보 처리방침")
//                        Text("이용약관")
                    }
                }
                .listStyle(.plain)
                .navigationTitle("설정")
                .alert(isPresented: $showLogoutAlert) {
                    Alert(
                        title: Text("로그아웃"),
                        message: Text("정말 로그아웃 하시겠습니까?"),
                        primaryButton: .destructive(Text("로그아웃")) {
                            signOut()
                        },
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
                .navigationDestination(isPresented: $shouldNavigateToSignIn) {
                    LoginView()
                        .navigationBarHidden(true)
                }
                
                
            }
        }//NavigationStack
        
        
    }
    func signOut() {
        do {
            try Auth.auth().signOut()
            AuthService.shared.userSession = nil
            DispatchQueue.main.async {
                self.shouldNavigateToSignIn = true // 로그인 화면으로 이동
            }
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

    

    
    


#Preview {
    SettingsAndInfo(currentUser: User.MOCK_USERS[0])
}
