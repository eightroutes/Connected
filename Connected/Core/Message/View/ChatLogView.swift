import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift

struct FirebaseConstants {
    static let timestamp = "timestamp"
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let profileImageUrl = "profile_image" // Firestore의 필드 이름에 맞춤
    static let email = "email"
    static let uid = "id"
    static let name = "Name"
}

struct ChatLogView: View {
    let user: User
    @ObservedObject var vm: ChatLogViewModel

    init(user: User) {
        self.user = user
        self.vm = ChatLogViewModel(user: user)
    }

    @State private var dynamicHeight: CGFloat = 32 // Initial height

    var body: some View {
        VStack {
            messagesView
            if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .foregroundColor(.red)
            }
            chatBottomBar
        }
        .navigationTitle(user.name ?? "")
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
    }

    static let emptyScrollToString = "Empty"

    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack { Spacer() }
                        .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .ignoresSafeArea(.keyboard)
    }

    private var chatBottomBar: some View {
        HStack(alignment: .bottom, spacing: 18) {
            Button(action: {
                // 사진 선택 액션
            }) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
            }

            ZStack {
                if vm.chatText.isEmpty {
                    Text("Message...")
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                TextEditor(text: $vm.chatText)
                    .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: vm.chatText) { _ in
                        adjustHeight()
                    }
            }
            .frame(height: dynamicHeight)

            Button(action: {
                if !vm.chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    vm.handleSend(text: vm.chatText)
                    vm.chatText = ""
                    dynamicHeight = 32 // Reset height
                }
            }) {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(vm.chatText.isEmpty ? Color.gray : Color.brand)
            .cornerRadius(4)
            .disabled(vm.chatText.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func adjustHeight() {
        let maxHeight: CGFloat = 120
        let minHeight: CGFloat = 32

        let textView = UITextView()
        textView.text = vm.chatText
        textView.font = UIFont.systemFont(ofSize: 17)
        let size = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 110, height: .infinity))
        dynamicHeight = min(max(size.height, minHeight), maxHeight)
    }
}

struct MessageView: View {
    let message: ChatMessage

    var body: some View {
        VStack {
            if message.fromId == Auth.auth().currentUser?.uid {
                HStack {
                    Spacer()
                    Text(message.text)
                        .padding()
                        .background(Color.brand)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                HStack {
                    Text(message.text)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}



#Preview {
    ChatLogView(user: User(id: "FlqH2Rcg74a3p6ZsvHGEbyFJorz2", name: "Test User", profileImageUrl: "https://i.pravatar.cc/300", email: "rmsgh1188@gmail.com"))
}
