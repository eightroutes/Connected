import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct interests: View {
    
    @State private var showNextScreen = false
    @State private var intr = [String]()
    
    let db = Firestore.firestore()
    
    let user: User
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width/7*5, height: 5)
                        .padding(.leading, -200)
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: 5)
                        .foregroundStyle(Color.gray)
                        .opacity(0.2)
                }
                
                VStack {
                    Text("관심사는 무엇인가요?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 70.0)
                
                Rectangle()
                    .frame(width:UIScreen.main.bounds.width, height: 1)
                    .foregroundStyle(Color.gray)
                    .padding(.bottom, 5)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        interestRow(["축구", "노래", "산책", "야구", "헬스장" ])
                        interestRow(["농구", "수영", "영화", "애니메이션"])
                        interestRow(["사업", "프리랜서", "프로그래밍", "주식"])
                        interestRow(["힙합", "아쿠아리움", "음악제작", "카페"])
                        interestRow(["여행", "유튜브", "사진", "요리"])
                        interestRow(["등산", "격투기", "포켓몬", "암호화폐"])
                        interestRow(["오토바이", "자동차", "크로스핏", "패션"])
                        interestRow(["드라이브", "디자인", "창업", "부동산"])
                        interestRow(["AI", "게임개발", "마블시리즈", "VR"])
                        interestRow(["메타버스", "닌텐도", "콘서트", "클럽"])
                        interestRow(["콘텐츠 제작", "SF", "예술", "PC방"])
                        interestRow(["활동적인 라이프스타일", "조용한 라이프스타일"])
                        interestRow(["넷플릭스", "맛집탐방", "러닝", "요가"])
                        interestRow(["대화", "익스트림 스포츠"])
                    }
                    .padding(.horizontal, 5) // Add horizontal padding to the VStack
                }
                
                VStack {
                    Rectangle()
                        .frame(width:UIScreen.main.bounds.width, height: 1)
                        .foregroundStyle(Color.gray)
                        .padding(.bottom, 20)
                    
                    
                    Button(action: {
                        // Add a new document with a generated ID
                        
                        Task {
                            
                            do {
                                // 현재 로그인한 사용자의 UID 가져오기
                                guard let userId = Auth.auth().currentUser?.uid else {
                                    print("No user is signed in.")
                                    return
                                }
                                
                                // 사용자 UID를 사용하여 문서 업데이트 또는 생성
                                try await db.collection("users").document(userId).setData([
                                    "Interests": intr
                                ], merge: true)  // merge: true를 사용하여 기존 데이터를 유지하면서 업데이트
                                
                                print("Document updated for user: \(userId)")
                                showNextScreen = true
                            } catch {
                                print("Error updating document: \(error)")
                            }
                            
                        }}) {
                            Text("다음 \(intr.count)/5")
                                .frame(width: 250)
                                .foregroundColor(.white)
                                .padding()
                                .background(intr.count >= 5 ? .black : .unselectedButton)
                                .cornerRadius(30)
                        }
                        .disabled(intr.count < 5)
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/interests.swift
                        .background(NavigationLink(destination: ProfileImageSetting(), isActive: $showNextScreen){})
                    
========
                        .navigationDestination(isPresented: $showNextScreen)
                        {
                            ProfileImageSetting(user: user)
                        }
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/Interests.swift
                }
                
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }//NavigationStack
        .tint(.black)
    }
        
        @ViewBuilder
        private func interestRow(_ interestsArray: [String]) -> some View {
            HStack(spacing: 10) {
                ForEach(interestsArray, id: \.self) { interest in
                    intrButton(intrStr: interest, interests: $intr)
                }
            }
        }

    }
    






#Preview {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/interests.swift
    interests()
========
    Interests(user: User.MOCK_USERS[0])
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/Interests.swift
}

struct intrButton: View {
    
    let intrStr: String?
    
    @Binding var interests: [String]
    
    var body: some View {
        Button(action:{
            if interests.contains(intrStr!) {
                interests.removeAll(where: { $0 == intrStr })
            } else {
                interests.append(intrStr!)
            }
        }) {
            Text(intrStr!)
                .fontWeight(.bold)
                .frame(height: 5)
                .foregroundColor(interests.contains(intrStr!) ? .primary : .unselected)
                .padding()
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(interests.contains(intrStr!) ? Color.primary : Color.unselected, lineWidth: 2))
        }
    }
}






