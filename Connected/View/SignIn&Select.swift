//
//  SignIn.swift
//  Connected
//
//  Created by 정근호 on 4/15/24.
//

import SwiftUI

struct SignIn: View {
    
    var body: some View {
        NavigationView{
            VStack{
                Image("SplashLogo")
                    .resizable()
                    .frame(width:190, height: 119.19)
                    .padding(.top, 200.0)
                Text("CONNECTED")
                    .padding(.top, 10)
                    .fontWeight(.bold)
                    .font(.title)
                Spacer()
                VStack{
                    NavigationLink(destination: name()){
                        ZStack{
                            Image("xGoogle Login")
                            Text("Google로 로그인")
                                .foregroundStyle(Color.black)
                            
                        }
                    }
                 
                    NavigationLink(destination: name()){
                        ZStack{
                            Image("xApple ID Login")
                            Text("Apple로 로그인")
                                .foregroundStyle(Color.white)
                        }
                    }
                    
                    NavigationLink(destination: name()){
                        ZStack{
                            Image("xKakao Login")
                            Text("카카오톡 로그인")
                                .foregroundStyle(Color.black)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
}



#Preview {
    SignIn()
}

    

