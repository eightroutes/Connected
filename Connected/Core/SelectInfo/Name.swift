import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct name: View {
    @State private var inputName = ""
    @State private var showNextScreen = false
    
    let db = Firestore.firestore()
    
    let user: User

    
    var body: some View {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/name.swift
        NavigationStack(path: $navigationPath) {
            
========
        NavigationStack {
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/Name.swift
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width/7*1, height: 5)
                            .padding(.leading, -200)
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
//                    .padding(.top, 40)
                    
                    Spacer()
                    Text("이름이 무엇인가요?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    TextField("이름을 입력하세요", text: $inputName)
                        .padding(.leading, 70.0)
                    Rectangle()
                        .frame(width: 250, height: 0.5)
                    Spacer()
                }
                .padding(.bottom, 400)
                
                VStack {
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
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/name.swift
                    .background(
                        NavigationLink(destination: birthday(), isActive: $showNextScreen) {
                        })
                }
            }
            .accentColor(.black)
            .ignoresSafeArea(.keyboard)

//            .navigationBarBackButtonHidden(true)
        }
========
                    .navigationDestination(isPresented: $showNextScreen)
                    {
                        Birthday(user: user)
                    }
                    
                }
                .ignoresSafeArea(.keyboard)
                .navigationBarBackButtonHidden(true)
            }
        }//NavigationStack
        .tint(.black)
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/Name.swift
    }
}

#Preview {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/name.swift
    name()
========
    Name(user: User.MOCK_USERS[0])
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/Name.swift
}


//                            do {
//                                let ref = try await db.collection("users").addDocument(data: [
//                                    "Name": inputName
//                                ])
//                                print("Document added with ID: \(ref.documentID)")
//                                showNextScreen = true
//                            } catch {
//                                print("Error adding document: \(error)")
//                            }
//                            print("입력한 이름: \(inputName)")
