import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase
import Kingfisher

struct ProfileView: View {
    @StateObject private var viewModel = ProfileDetailViewModel()
    
    let user: User
    var radius: CGFloat = 60

    var body: some View {
        VStack {
            // 프로필 이미지가 존재할 경우
            if let profileImageUrl = viewModel.profileImageUrl, !profileImageUrl.isEmpty {
                // 현재 사용자일 경우 NotificationView로 네비게이션
                if user.id == Auth.auth().currentUser?.uid {
                    NavigationLink(destination: NotificationView()) {
                        KFImage(URL(string: profileImageUrl))
                            .resizable()
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 1)
                            )
                            .shadow(radius: 1)
                            .frame(width: self.radius, height: self.radius)
                    }
                } else {
                    // 다른 사용자일 경우 ProfileDetail로 네비게이션
                    NavigationLink(destination: ProfileDetail(user: user)) {
                        KFImage(URL(string: profileImageUrl))
                            .resizable()
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 1)
                            )
                            .shadow(radius: 1)
                            .frame(width: self.radius, height: self.radius)
                    }
                }
            } else {
                // 프로필 이미지가 없을 경우 기본 이미지 사용
                if user.id == Auth.auth().currentUser?.uid {
                    NavigationLink(destination: NotificationView()) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: self.radius, height: self.radius)
                            .foregroundColor(.gray)
                            .shadow(radius: 1)
                    }
                } else {
                    NavigationLink(destination: ProfileDetail(user: user)) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: self.radius, height: self.radius)
                            .foregroundColor(.gray)
                            .shadow(radius: 1)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchUserProfile(for: user.id)
        }
    }
}

#Preview {
    ProfileView(user: User.MOCK_USERS[0])
}

