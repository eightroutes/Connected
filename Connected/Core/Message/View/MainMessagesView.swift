import SwiftUI
import Firebase
import Kingfisher
import FirebaseFirestoreSwift

struct MainMessagesView: View {
    let user: User
    @ObservedObject var vm: MainMessagesViewModel
    
    init(user: User) {
        self.user = user
        self.vm = MainMessagesViewModel(user: user)
    }
    
    @State var shouldShowLogOutOptions = false
    @State private var selectedProfileUser: User?
    @State private var shouldNavigateToChatLogView = false
    @State private var shouldNavigateToProfileDetail = false
    


    var body: some View {
        NavigationStack {
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
    }

    private var messagesView: some View {
        ScrollView {
            Spacer()
                .frame(height: 8)
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    HStack(spacing: 16) {
                        // 프로필 이미지 버튼
                        Button {
                            self.selectedProfileUser = recentMessage.user
                            self.shouldNavigateToProfileDetail = true
                        } label: {
                            KFImage(URL(string: recentMessage.user.profileImageUrl ?? ""))
                                .onSuccess { _ in
                                    print("Loaded image for message from \(recentMessage.user.name ?? "")")
                                }
                                .onFailure { error in
                                    print("Failed to load image: \(error.localizedDescription)")
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(Circle().stroke(Color(.label), lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading) {
                            // 메시지 내용 및 채팅 화면으로 이동
                            Button {
                                self.selectedProfileUser = recentMessage.user
                                self.shouldNavigateToChatLogView = true
                                print("Navigating to ChatLogView with user: \(self.selectedProfileUser?.name ?? "No Name")")
                            } label: {
                                VStack(alignment: .leading){
                                    Text(recentMessage.user.name ?? "UserName")
                                        .font(.system(size: 16, weight: .bold))
                                        .lineLimit(1)
                                    Text(recentMessage.text)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text(recentMessage.timeAgo)
                            .foregroundColor(Color(.lightGray))
                            .font(.system(size: 14, weight: .semibold))
                    } // HStack
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                } // VStack
            }
//            .padding(.bottom, 50)
        }
    }
}

#Preview {
    MainMessagesView(user: User(id: "FlqH2Rcg74a3p6ZsvHGEbyFJorz2", name: "Test User", profileImageUrl: "https://i.pravatar.cc/300", email: "rmsgh1188@gmail.com"))
}
