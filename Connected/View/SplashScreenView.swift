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

    @EnvironmentObject var viewModel: signInViewModel
    
    
    
    var body: some View {
        
        if isActive {
            if viewModel.isSignedIn {
                mainView()
            } else {
                signIn()
            }
//             mainView()
        } else{
            VStack{
                VStack{
                    Image("SplashLogo")
//                        .font(Font.custom("Baskerville-Bold", size: 26))
//                        .foregroundStyle(.black.opacity(0.10))
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
        .environmentObject(signInViewModel()) // 미리보기에서 viewModel을 설정합니다.
}
