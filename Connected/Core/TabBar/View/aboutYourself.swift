//
//  6_aboutYou.swift
//  Connected
//
//  Created by 정근호 on 4/15/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct aboutYourself: View {
    
    @State private var showNextScreen = false
    @State private var selectedColor: String?
    @State private var selectedMBTI: String?
    @State private var musicGenres = [String]()
    @State private var movieGenres = [String]()
    
    let db = Firestore.firestore()
    
    let user: User
    
    var body: some View {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/aboutYourself.swift
        NavigationStack(path: $navigationPath){
========
        NavigationStack {
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/AboutYourself.swift
            VStack {
                ZStack {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width/7*4, height: 5)
                        .padding(.leading, -200)
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: 5)
                        .foregroundStyle(Color.gray)
                        .opacity(0.2)
                }
                
                VStack {
                    Text("본인에 대해 알려주세요")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 70.0)
            }
            
            
            Rectangle()
                .frame(width:UIScreen.main.bounds.width, height: 1)
                .foregroundStyle(Color.gray)
            //            .padding(.bottom, 10.0)
            
            ScrollView {
                ZStack {
                    VStack {
                        VStack(alignment: .leading){
                            Text("좋아하는 색은?")
                                .padding(.vertical, 5.0)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .padding(.leading, 5.0)
                            
                            HStack{
                                colorButton(color: "red", colorStr: "빨간색", colorCode: .red, selectedColor: $selectedColor)
                                colorButton(color: "orange", colorStr: "주황색", colorCode: .orange , selectedColor: $selectedColor)
                                colorButton(color: "yellow", colorStr: "노란색", colorCode: .yellow, selectedColor: $selectedColor)
                                colorButton(color: "green", colorStr: "초록색", colorCode: .green, selectedColor: $selectedColor)
                                
                            }
                            HStack{
                                colorButton(color: "blue", colorStr: "파란색", colorCode: .blue, selectedColor: $selectedColor)
                                colorButton(color: "purple", colorStr: "보라색", colorCode: .purple, selectedColor: $selectedColor)
                                colorButton(color: "white", colorStr: "하얀색", colorCode: .white, selectedColor: $selectedColor)
                                colorButton(color: "gray", colorStr: "회색", colorCode: .gray, selectedColor: $selectedColor)
                                
                            }
                            colorButton(color: "black", colorStr: "검은색", colorCode: .black, selectedColor: $selectedColor)
                                .padding(.bottom, 5)
                            //                                .padding(.leading, -169.0)
                            
                            Rectangle()
                                .frame(width:UIScreen.main.bounds.width - 40, height: 1)
                                .foregroundStyle(Color.gray)
                            
                            Text("MBTI는 무엇인가요?")
                                .padding(.vertical, 5)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .padding(.leading, 5)
                            
                            HStack{
                                mbtiButton(mbti: "intj", mbtiStr: "INTJ", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "intp", mbtiStr: "INTP", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "entj", mbtiStr: "ENTJ", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "entp", mbtiStr: "ENTP", selectedMBTI: $selectedMBTI)                            }
                            HStack{
                                mbtiButton(mbti: "infp", mbtiStr: "INFP", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "enfj", mbtiStr: "ENFJ", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "enfp", mbtiStr: "ENFP", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "istj", mbtiStr: "ISTJ", selectedMBTI: $selectedMBTI)
                            }
                            HStack{
                                mbtiButton(mbti: "isfj", mbtiStr: "ISFJ", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "estj", mbtiStr: "ESTJ", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "esfj", mbtiStr: "ESFJ", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "istp", mbtiStr: "ISTP", selectedMBTI: $selectedMBTI)
                            }
                            HStack{
                                mbtiButton(mbti: "isfp", mbtiStr: "ISFP", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "estp", mbtiStr: "ESTP", selectedMBTI: $selectedMBTI)
                                mbtiButton(mbti: "esfp", mbtiStr: "ESFP", selectedMBTI: $selectedMBTI)
                                
                            }
                            .padding(.bottom, 5)
                            
                            Rectangle()
                                .frame(width:UIScreen.main.bounds.width - 40, height: 1)
                                .foregroundStyle(Color.gray)
                            
                            Text("좋아하는 음악 장르는?")
                                .padding(.vertical, 5)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .padding(.leading, 5)
                            
                            
                            HStack {
                                musicButton(musicStr: "POP", musicGenres: $musicGenres)
                                musicButton(musicStr: "발라드", musicGenres: $musicGenres)
                                musicButton(musicStr: "R&B", musicGenres: $musicGenres)
                                musicButton(musicStr: "Hip-hop", musicGenres: $musicGenres)
                                
                            }
                            HStack {
                                musicButton(musicStr: "EDM", musicGenres: $musicGenres)
                                musicButton(musicStr: "Rock", musicGenres: $musicGenres)
                                musicButton(musicStr: "K-POP", musicGenres: $musicGenres)
                                musicButton(musicStr: "J-POP", musicGenres: $musicGenres)
                                
                            }
                            HStack {
                                musicButton(musicStr: "Synthwave", musicGenres: $musicGenres)
                                musicButton(musicStr: "컨트리", musicGenres: $musicGenres)
                                musicButton(musicStr: "Latin", musicGenres: $musicGenres)
                            }
                            .padding(.bottom, 5)
                            
                            Rectangle()
                                .frame(width:UIScreen.main.bounds.width - 40, height: 1)
                                .foregroundStyle(Color.gray)
                            Text("좋아하는 영화, 드라마 장르는?")
                                .padding(.vertical, 5)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .padding(.leading, 5)
                            
                            HStack{
                                movieButton(movieStr: "액션", movieGenres: $movieGenres)
                                movieButton(movieStr: "범죄", movieGenres: $movieGenres)
                                movieButton(movieStr: "SF", movieGenres: $movieGenres)
                                movieButton(movieStr: "공포", movieGenres: $movieGenres)
                                movieButton(movieStr: "전쟁", movieGenres: $movieGenres)
                            }
                            HStack{
                                movieButton(movieStr: "스릴러", movieGenres: $movieGenres)
                                movieButton(movieStr: "스포츠", movieGenres: $movieGenres)
                                movieButton(movieStr: "판타지", movieGenres: $movieGenres)
                                movieButton(movieStr: "뮤지컬", movieGenres: $movieGenres)
                            }
                            HStack{
                                movieButton(movieStr: "음악", movieGenres: $movieGenres)
                                movieButton(movieStr: "역사", movieGenres: $movieGenres)
                                
                            }
                            
                            
                            
                        }
                        .padding(.bottom, -200.0)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 400)
                
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
                                "Color": selectedColor!,
                                "MBTI": selectedMBTI!,
                                "Music": musicGenres,
                                "Movie": movieGenres
                            ], merge: true)  // merge: true를 사용하여 기존 데이터를 유지하면서 업데이트
                            
                            print("Document updated for user: \(userId)")
                            print(selectedColor!)
                            print(selectedMBTI!)
                            print(musicGenres)
                            print(movieGenres)
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
                        .background((selectedMBTI == nil || selectedColor == nil || musicGenres.isEmpty || movieGenres.isEmpty) ? .unselectedButton : .black)
                        .cornerRadius(30)
                }
                .disabled(selectedMBTI == nil || selectedColor == nil || musicGenres.isEmpty || movieGenres.isEmpty)
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/aboutYourself.swift
                .background(
                    NavigationLink(destination: interests(), isActive: $showNextScreen) {
                    }
                )
                
            }
            .tint(.black)
//            .background(Color.brandBack)
        }
        
========
                .navigationDestination(isPresented: $showNextScreen)
                {
                    Interests(user: user)
                }
            }
        }//NavigationStack
        .tint(.black)
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/AboutYourself.swift
    }
}

#Preview {
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/aboutYourself.swift
    aboutYourself()
========
    AboutYourself(user: User.MOCK_USERS[0])
>>>>>>>> Stashed changes:Connected/Core/SelectInfo/AboutYourself.swift
}


struct colorButton: View {
    
    let color: String
    let colorStr: String
    let colorCode: Color
    
    @Binding var selectedColor: String?
    
    var body: some View {
        Button(action:{
            self.selectedColor = color
        }) {
            Text(colorStr)
                .fontWeight(.bold)
                .frame(width: 50, height: 5)
                .padding()
                .foregroundColor((selectedColor == color ? colorCode : .unselected))
                .background(Color.clear)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30).stroke((selectedColor == color ? colorCode : .unselected), lineWidth: 2) // 테두리 색상과 두께 설정
                )
            
        }
    }
}

struct mbtiButton: View {
    
    let mbti: String
    let mbtiStr: String
    
    @Binding var selectedMBTI: String?
    
    var body: some View {
        Button(action:{
            selectedMBTI = mbti
        }) {
            Text(mbtiStr)
                .fontWeight(.bold)
                .font(.body)
                .frame(width: 50, height: 5)
                .foregroundColor(selectedMBTI == mbti ? .primary : .unselected)
                .padding()
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(selectedMBTI == mbti ? Color.primary : Color.unselected, lineWidth: 2))
        }
    }
}

struct musicButton: View {
    
    let musicStr: String?
    
    @Binding var musicGenres: [String]
    
    var body: some View {
        Button(action:{
            if musicGenres.contains(musicStr!){
                musicGenres.removeAll(where: { $0 == musicStr })
            }
            else{
                musicGenres.append(musicStr!)
            }
        }) {
            Text(musicStr!)
                .fontWeight(.bold)
                .frame(height: 5)
                .foregroundColor(musicGenres.contains(musicStr!) ? .primary : .unselected)
                .padding()
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(musicGenres.contains(musicStr!) ? Color.primary : Color.unselected, lineWidth: 2))
        }
    }
}

struct movieButton: View {
    
    let movieStr: String?
    
    @Binding var movieGenres: [String]
    
    var body: some View {
        Button(action:{
            if movieGenres.contains(movieStr!){
                movieGenres.removeAll(where: { $0 == movieStr })
            }
            else{
                movieGenres.append(movieStr!)
            }
        }) {
            Text(movieStr!)
                .fontWeight(.bold)
                .frame(height: 5)
                .foregroundColor(movieGenres.contains(movieStr!) ? .primary : .unselected)
                .padding()
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(movieGenres.contains(movieStr!) ? Color.primary : Color.unselected, lineWidth: 2))
        }
    }
}
