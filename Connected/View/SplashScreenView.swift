//
//  SplashScreenView.swift
//  Connected
//
//  Created by 정근호 on 4/8/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    
    var body: some View {
        if isActive {
            signIn()
        } else{
            VStack{
                VStack{
                    Image("SplashLogo")
//                        .font(Font.custom("Baskerville-Bold", size: 26))
//                        .foregroundStyle(.black.opacity(0.80))
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
}
