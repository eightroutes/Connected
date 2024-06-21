import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct name: View {
    @State private var inputName = ""
    @State private var showNextScreen = false
    @State private var navigationPath = NavigationPath()
    
    let db = Firestore.firestore()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width/6, height: 5)
                            .padding(.leading, -200)
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
                    .padding(.top, 40)
                    
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
                                let ref = try await db.collection("users").addDocument(data: [
                                    "Name": inputName
                                ])
                                print("Document added with ID: \(ref.documentID)")
                                showNextScreen = true
                            } catch {
                                print("Error adding document: \(error)")
                            }
                            print("입력한 이름: \(inputName)")
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
                    .background(
                        NavigationLink(destination: birthday(), isActive: $showNextScreen) {
                            EmptyView()
                        }
                        .hidden()
                    )
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .accentColor(.black)
    }
}

#Preview {
    name()
}

