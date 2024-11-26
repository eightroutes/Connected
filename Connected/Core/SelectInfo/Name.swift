import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct Name: View {
    @State private var inputName = ""
    @State private var showNextScreen = false
    
    let db = Firestore.firestore()
    
    let user: User
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width/8*1, height: 5)
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                    
                
                    VStack {
                        
                        Text("이름이 무엇인가요?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 60)
                        HStack {
                            TextField("이름을 입력하세요", text: $inputName)
                                .padding(.leading, 70.0)
                                .onChange(of: inputName) { newValue in
                                    if newValue.count > 10 {
                                        inputName = String(newValue.prefix(10))
                                    }
                                }
                            
                            Text("\(inputName.count)/10자")
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.footnote)
                                .padding(.leading, 80)
                        }
                        
                        Rectangle()
                            .frame(width: 250, height: 0.5)
                        
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            do {
                                // 현재 로그인한 사용자의 UID 가져오기
                                guard let userId = Auth.auth().currentUser?.uid else {
                                    print("No user is signed in.")
                                    return
                                }
                                
                                // 사용자 UID를 사용하여 문서 업데이트 또는 생성
                                try await db.collection("users").document(userId).setData([
                                    "Name": inputName
                                ], merge: true)  // merge: true를 사용하여 기존 데이터를 유지하면서 업데이트
                                
                                print("Document updated for user: \(userId)")
                                showNextScreen = true
                            } catch {
                                print("Error updating document: \(error)")
                            }
                            
                        }
                    }) {
                        Text("다음")
                            .frame(width: 250)
                            .foregroundColor(.white)
                            .padding()
                            .background(inputName.isEmpty ? Color.unselectedButton : Color.black)
                            .cornerRadius(30)
                    }
                    .disabled(inputName.isEmpty)
                    .navigationDestination(isPresented: $showNextScreen)
                    {
                        Birthday(user: user)
                    }
                    
                    
                }
            }
        }//NavigationStack
        .navigationBarBackButtonHidden(true)
        .tint(.black)
        .ignoresSafeArea(.keyboard)
        
    }
    
}

#Preview {
    Name(user: User.MOCK_USERS[0])
}

