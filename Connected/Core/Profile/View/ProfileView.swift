import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase
import Kingfisher

struct ProfileView: View {
    @StateObject private var viewModel = ProfileDetailViewModel()
    
    let user: User

    var body: some View {
        NavigationStack {
            VStack {
                if let profileImageUrl = viewModel.profileImageUrl {
                    // 프로필 이미지가 존재할 경우
                    NavigationLink(destination: NotificationView()) {
                        KFImage(URL(string: profileImageUrl))
                            .resizable()
                            .clipShape(Circle())
                            .overlay {
                                Circle().stroke(Color.white, lineWidth: 2)
                            }
                            .shadow(radius: 2)
                            .frame(width: 60, height: 60)
                    }
                    .zIndex(1.0)
                } else {
                    // 프로필 이미지가 없을 경우 기본 이미지 사용
                    NavigationLink(destination: NotificationView()) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    }
                    .zIndex(1.0)
                }
            }
            
            .onAppear {
                viewModel.fetchUserProfile(for: user.id)
            }
        }//NavigationStack
        .tint(.black)
    }
}


#Preview {
    ProfileView(user: User.MOCK_USERS[0])
}
