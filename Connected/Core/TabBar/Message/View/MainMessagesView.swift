import SwiftUI
import Firebase
import Kingfisher
import FirebaseFirestoreSwift

struct MainMessagesView: View {
    @ObservedObject var vm: MainMessagesViewModel
    
    @State var shouldShowLogOutOptions = false
    @State private var selectedProfileUser: User?
    @State private var shouldNavigateToChatLogView = false
    @State private var shouldNavigateToProfileDetail = false
    
    init(user: User) {
        self.vm = MainMessagesViewModel()
    }
    
    var body: some View {
            VStack {
                messagesView
            }
            .navigationTitle("메시지")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                if let user = selectedProfileUser {
                    ChatLogView(user: user)
                }
            }
            .navigationDestination(isPresented: $shouldNavigateToProfileDetail) {
                if let user = selectedProfileUser {
                    ProfileDetail(user: user)
                }
            }
        
    }
    
    private var messagesView: some View {
        ScrollView {
            Spacer()
                .frame(height: 8)
            VStack(alignment: .leading){
                if (vm.recentMessages.isEmpty) {
                    Text("메시지가 없습니다.")
                    
                }
            }
            ForEach(vm.recentMessages) { recentMessage  in
                VStack {
                    HStack(spacing: 16) {
                        // 프로필 이미지 버튼
                        Button {
                            self.shouldNavigateToProfileDetail = true
                        } label: {
                            KFImage(URL(string: recentMessage.user.profile_image))
                                .onSuccess { _ in
                                    print("Loaded image for message from \(recentMessage.user.name)")
                                }
                                .onFailure { error in
                                    print("Failed to load image: \(error.localizedDescription)")
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(Circle().stroke(Color(.white), lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading) {
                            // 메시지 내용 및 채팅 화면으로 이동
                            Button {
                                self.selectedProfileUser = convertToUser(userBrief: recentMessage.user)
                                self.shouldNavigateToChatLogView = true
                                print("Navigating to ChatLogView with user: \(self.selectedProfileUser?.name ?? "No Name")")
                            } label: {
                                VStack(alignment: .leading){
                                    Text(recentMessage.user.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .lineLimit(1)
                                    Text(recentMessage.text)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text(timeAgo(from: recentMessage.timestamp))
                            .foregroundColor(Color(.lightGray))
                            .font(.system(size: 14, weight: .semibold))
                    } // HStack
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                }// VStack
                .onAppear(){
                    self.selectedProfileUser = convertToUser(userBrief: recentMessage.user)
                }
            }
        }
        
    }
    
    // Helper method to convert UserBrief to User
    private func convertToUser(userBrief: RecentMessage.UserBrief) -> User? {
        // Firestore에서 User 데이터를 가져와야 합니다.
        // 또는, 이미 모든 필드가 저장되어 있으므로 UserBrief와 User를 통합할 수 있습니다.
        // 여기서는 UserBrief를 기반으로 User를 생성하는 예시를 제공합니다.
        // 실제 애플리케이션에서는 추가적인 데이터 조회가 필요할 수 있습니다.
        
        // 예시: UserBrief와 User가 동일한 필드를 가진 경우
        return User(
            id: userBrief.id,
            name: userBrief.name,
            gender: nil,
            interests: nil,
            selectedColor: nil,
            selectedMBTI: nil,
            musicGenres: nil,
            movieGenres: nil,
            profileImageUrl: userBrief.profile_image,
            otherImagesUrl: nil,
            latitude: nil,
            longitude: nil,
            email: userBrief.email,
            age: nil,
            birthday: nil
        )
    }
    
    // Helper method to format timestamp
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}


#Preview {
    MainMessagesView(user: User(id: "FlqH2Rcg74a3p6ZsvHGEbyFJorz2", name: "Test User", profileImageUrl: "https://i.pravatar.cc/300", email: "rmsgh1188@gmail.com"))
}
