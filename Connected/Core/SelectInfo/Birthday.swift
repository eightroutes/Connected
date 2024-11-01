import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct Birthday: View {
    
    @State private var showNextScreen = false
    @State private var selectedDate = Date()
    
    let db = Firestore.firestore()
    
    let user: User
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ZStack(alignment: .leading){
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width/7*2, height: 5)
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
                    Spacer()
                    
                    Text("생일이 언제인가요?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    DatePicker("Please enter a date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding(.bottom, -50)
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
                                    "Birthday": selectedDate
                                ], merge: true)  // merge: true를 사용하여 기존 데이터를 유지하면서 업데이트
                                
                                print("Document updated for user: \(userId)")
                                showNextScreen = true
                            } catch {
                                print("Error updating document: \(error)")
                            }
                            
                        }
                        //                            Task {
                        //                                do {
                        //                                    let ref = try await db.collection("users").addDocument(data: [
                        //                                        "Birthday": selectedDate
                        //                                    ])
                        //                                    print("Document added with ID: \(ref.documentID)")
                        //                                } catch {
                        //                                    print("Error adding document: \(error)")
                        //                                }
                        //                                showNextScreen = true
                    }) {
                        Text("다음")
                            .frame(width: 250)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(30)
                    }
                    .navigationDestination(isPresented: $showNextScreen)
                    {
                        Gender(user: user)
                    }
                }
            }//ZStack
            .tint(.black)
        }//NavigationStack
    }
}

#Preview {
    Birthday(user: User.MOCK_USERS[0])
}
