import SwiftUI
import Firebase
import Kingfisher
import FirebaseFirestore

struct MainMessagesView: View {
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    @State private var selectedChatUser: ChatUser?
    @State private var shouldNavigateToChatLogView = false

    var body: some View {
        NavigationStack {
            VStack {
                customNavBar
                messagesView
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                if let chatUser = selectedChatUser {
                    ChatLogView(chatUser: chatUser)
                }
            }
        }
    }

    private var customNavBar: some View {
        HStack(spacing: 16) {
            // Use vm.chatUser instead of currentUser
            KFImage(URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(vm.chatUser?.name ?? "UserName")
                    .font(.system(size: 24, weight: .bold))

                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }

            Spacer()
        }
        .padding()
    }

    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let id = recentMessage.toId == Auth.auth().currentUser?.uid ? recentMessage.fromId : recentMessage.toId
                        let data = [
                            "id": id,
                            "email": recentMessage.email,
                            "profile_image": recentMessage.profileImageUrl,
                            "Name": recentMessage.name
                        ]
                        self.selectedChatUser = ChatUser(data: data)
                        self.shouldNavigateToChatLogView = true
                    } label: {
                        Spacer()
                            .frame(height: 8)
                        HStack(spacing: 16) {
                            KFImage(URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(Circle()
                                            .stroke(Color(.label), lineWidth: 1))

                            VStack(alignment: .leading) {
                                Text(recentMessage.name)
                                    .font(.system(size: 16, weight: .bold))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(recentMessage.timeAgo)
                                .foregroundColor(Color(.lightGray))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal)
                    }

                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    MainMessagesView()
}
