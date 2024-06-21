//
//  4_gender.swift
//  Connected
//
//  Created by 정근호 on 4/15/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct gender: View {
    
    @State private var showNextScreen = false
    @State private var selectedGender: String? = nil
    @State private var navigationPath = NavigationPath()
    
    
    enum Gender {
        case male, female
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width/6*3, height: 5)
                            .padding(.leading, -200)
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width, height: 5)
                            .foregroundStyle(Color.gray)
                            .opacity(0.2)
                    }
                    Spacer()
                    Text("성별이 무엇인가요?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    
                    Button(action: {
                        selectedGender = "male"
                    }) {
                        Text("남자")
                            .frame(width: 250)
                            .foregroundColor(selectedGender == "male" ? .white : .gray)
                            .padding()
                            .background(selectedGender == "male" ? Color.black : Color(UIColor.systemGray5))
                            .cornerRadius(30)
                        
                        
                    }
                    .padding(0.0)
                    Button(action: {
                        selectedGender = "female"
                    }) {
                        Text("여자")
                            .frame(width: 250)
                            .foregroundColor(selectedGender == "female" ? .white : .gray)
                            .padding()
                            .background(selectedGender == "female" ? Color.black : Color(UIColor.systemGray5))
                            .cornerRadius(30)
                    }
                    .padding(0.0)
                    
                }
                .padding(.bottom, 400)
                
                VStack {
                    Spacer()
                    Button(action: {
                        if selectedGender != nil {
                            print("성별: \(selectedGender ?? "no sex")")
                            showNextScreen = true
                        }
                        
                    }) {
                        Text("다음")
                            .frame(width: 250)
                            .foregroundColor(.white)
                            .padding()
                            .background(selectedGender == nil ? .unselectedButton: .black)
                            .cornerRadius(30)
                    }
                    .disabled(selectedGender == nil)
                    .background(NavigationLink(destination: aboutYourself(), isActive: $showNextScreen) {})
                    
                }
                
            }
        }
        .accentColor(.black)
    }
}

#Preview {
    gender()
}
