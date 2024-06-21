import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct birthday: View {
    
    @State private var showNextScreen = false
    @State private var selectedDate = Date()
    @State private var navigationPath = NavigationPath()
    
    let db = Firestore.firestore()
    
    
    var body: some View {
        NavigationStack{
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width/6*2, height: 5)
                            .padding(.leading, -200)
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
                    NavigationLink(destination: gender(), isActive: $showNextScreen){
                        Button(action: {
                            Task {
                                do {
                                    let ref = try await db.collection("users").addDocument(data: [
                                        "Birthday": selectedDate
                                    ])
                                    print("Document added with ID: \(ref.documentID)")
                                } catch {
                                    print("Error adding document: \(error)")
                                }
                                showNextScreen = true
                            }}) { 
                                Text("다음")
                                    .frame(width: 250)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(30)
                            }
                    }
                }
            }
           
        }
        .accentColor(.black)
    }
}

#Preview {
    birthday()
}
