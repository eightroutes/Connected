
import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct FirebaseConstants {
    static let timestamp = "timestamp"
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let profileImageUrl = "profile_image"
    static let email = "email"
    static let uid = "id"
    static let name = "Name"
}


struct ChatLogView: View {
    
    let chatUser: ChatUser
    @ObservedObject var vm: ChatLogViewModel
    
    init(chatUser: ChatUser) {
        self.chatUser = chatUser
        self.vm = ChatLogViewModel(chatUser: chatUser)
    }
    
    @State private var dynamicHeight: CGFloat = 16 // 초기 높이 설정

    
    
    var body: some View {
        
        VStack {
            
            messagesView
            Text(vm.errorMessage)
            
            chatBottomBar
            
        }
        .navigationTitle(chatUser.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListner?.remove()
        }
//        .navigationBarItems(trailing: Button(action: {
//            vm.count += 1
//        }, label: {
//            Text("Count: \(vm.count)")
//        }))
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    
                    HStack{ Spacer() }
                        .id(Self.emptyScrollToString)
                }
                // 하단으로 스크롤
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                }

            }
            
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
    }
    
    
    private var chatBottomBar: some View {

        HStack(alignment:.bottom ,spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))

            TextEditor(text: $vm.chatText)
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight) // Set dynamic height
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: vm.chatText) { _ in
                    adjustHeight()
                }
            
//            DescriptionPlaceholder()
//            TextEditor(text: $vm.chatText)
//                .opacity(vm.chatText.isEmpty ? 0.5: 1)
                
//            TextField("Description", text: $vm.chatText)
//                .opacity(vm.chatText.isEmpty ? 0.5: 1)
            Button {
                if vm.chatText != "" {
                    vm.handleSend(text: vm.chatText)
                }
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(vm.chatText.isEmpty ? Color.gray: Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func adjustHeight() {
            let fixedWidth = UIScreen.main.bounds.width - 110 // Width of the HStack minus paddings
            let size = CGSize(width: fixedWidth, height: .infinity)
            let estimatedSize = vm.chatText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 17)], context: nil)
            let newHeight = max(20, min(estimatedSize.height + 20, 120)) // Set a maximum height limit of 120
            dynamicHeight = newHeight
        }
}

struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        NavigationStack {
            VStack {
                if message.fromId == Auth.auth().currentUser?.uid {
                    HStack {
                        Spacer()
                        HStack {
                            Text(message.text)
                                .foregroundColor(.white)
                            
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    
                } else {
                    HStack {
                        HStack {
                            Text(message.text)
                                .foregroundColor(.black)
                            
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        Spacer()
                    }
                }
            }//VStack
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}

//private struct DescriptionPlaceholder: View {
//    var body: some View {
//        HStack {
//            Text("Description")
//                .foregroundColor(.gray)
//                .font(.system(size: 17))
//                .padding(.leading, 5)
//                .padding(.top, -4)
//            Spacer()
//        }
//    }
//}

#Preview() {
    NavigationView {
        ChatLogView(chatUser: ChatUser(data: ["uid":"FlqH2Rcg74a3p6ZsvHGEbyFJorz2", "email":"rmsgh1188@gmail.com"]))
    }
   
}
