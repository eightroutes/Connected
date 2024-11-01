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

    @StateObject private var viewModel = ProfileDetailViewModel()

    
    
    var body: some View {
        
        if isActive {
            if viewModel.isSignedIn &&  viewModel.userImages.count >= 1 {
                mainView()
            } else {
                signIn()
            }
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/SplashScreenView.swift
//            signIn()
========
>>>>>>>> Stashed changes:Connected/Core/Authentication/View/SplashScreenView.swift
            
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
<<<<<<<< Updated upstream:Connected/Core/TabBar/View/SplashScreenView.swift
========

>>>>>>>> Stashed changes:Connected/Core/Authentication/View/SplashScreenView.swift
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
