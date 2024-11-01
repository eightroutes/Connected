//
//  CustomMarker.swift
//  Connected
//
//  Created by 정근호 on 8/15/24.
//

import SwiftUI
import Kingfisher


struct CustomMarker: View {
    @StateObject private var viewModel = ProfileDetailViewModel()

    let user: User
    let action: () -> Void

    var body: some View {
        VStack {
            if let profileImage = viewModel.profileImageUrl {
                KFImage(URL(string: profileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
            }
        }
//        .background(Color.white.opacity(0.1))
//        .clipShape(Circle())
//        .shadow(radius: 5)
        .onTapGesture(perform: action)
        .onAppear {
            viewModel.fetchUserProfile(for: user.id)
        }
    }
}

#Preview {
    CustomMarker(user: User.MOCK_USERS[0], action: {
        NotificationView()
    })
}
