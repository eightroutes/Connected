//
//  SplashScreenView.swift
//  Connected
//
//  Created by 정근호 on 4/8/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    
    // 초기값 설정
    @State private var size = 0.8
    @State private var opacity = 0.1

    @StateObject private var viewModel = SignInViewModel()

    
    
    var body: some View {
        
        if isActive {
            if viewModel.signState == .signIn {
                MainView()
            } else {
                SignIn()
            }
//            SignIn()
            
        } else{
            VStack{
                VStack{
                    Image("SplashLogo")

                }
                .scaleEffect(size)
//                .onAppear{
//                    withAnimation(.easeIn(duration: 1.2)){
//                        self.size = 0.9
//                        self.opacity = 1.0
//                    }
//                }
            }
            .tint(.black)
            .onAppear {
//                viewModel.checkAndUpdateSignInStatus() // 로그인 상태를 확인

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
