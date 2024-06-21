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
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            name()
        } else{
            VStack{
                VStack{
                    Image("SplashLogo")
//                    Text("Epic App 2")
//                        .font(Font.custom("Baskerville-Bold", size: 26))
//                        .foregroundStyle(.black.opacity(0.80))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
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
    name()
}
