//
//  test1.swift
//  Connected
//
//  Created by 정근호 on 5/31/24.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                print("Short button tapped!")

            }) {
                Text("Short")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
            }

            Button(action: {
                print("Medium length button tapped!")
            }) {
                Text("Medium Length")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
            }

            Button(action: {
                print("A very long text button tapped!")
            }) {
                Text("A Very Long Text Button")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct test1: View {
    @State private var showDetails = false
    
    var body: some View {
            VStack {
                Button(action: {
                    showDetails.toggle()
                }) {
                    Text("디테일 보기")
                }
     
                if showDetails {
                    Text("서근 개발블로그 구독 부탁드려요")
                        .font(.largeTitle)
                }
            }
        }
}

#Preview {
    test1()
}
