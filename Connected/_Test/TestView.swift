//
//  TestView.swift
//  Connected
//
//  Created by 정근호 on 10/12/24.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ControlTint: View {
    var body: some View {
        NavigationStack {
            HStack {
                NavigationLink {
                    // Answer the call
                        NextView()
                } label: {
                    Label("Answer", systemImage: "phone")
                }
                .tint(.green)
                Button {
                    // Decline the call
                } label: {
                    Label("Decline", systemImage: "phone.down")
                }
                .tint(.red)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .tint(.black)
    }
}

struct NextView: View {
    var body: some View {
        NavigationStack {
            HStack{
                Text("Hello!")
            }

        }
//        .tint(.black)
    }
}

#Preview {
    ControlTint()
}
