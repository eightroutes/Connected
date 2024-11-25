import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import PhotosUI
import FirebaseStorage

struct GroupChatView: View {
    let group: Groups
    @ObservedObject var vm: GroupChatViewModel
    
    init(group: Groups) {
        self.group = group
        self.vm = GroupChatViewModel(group: group)
    }
    
    @State private var dynamicHeight: CGFloat = 32 // Initial height
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @State private var isUploadingImage = false
    
    var body: some View {
        
        VStack {
            messagesView
            if !vm.errorMessage.isEmpty {
                Text(vm.errorMessage)
                    .foregroundColor(.red)
            }
            chatBottomBar
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
        .onChange(of: selectedImage) { _ in
            if let image = selectedImage {
                uploadImage(image)
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
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
                isPickerPresented = true
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
                if !vm.chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil {
                    if let image = selectedImage {
                        // 이미지가 선택된 경우 업로드 후 전송
                        uploadImage(image)
                    } else {
                        // 텍스트만 있는 경우 바로 전송
                        vm.handleSend(text: vm.chatText, imageUrl: nil)
                        vm.chatText = ""
                        dynamicHeight = 32 // Reset height
                    }
                }
            }) {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background((!vm.chatText.isEmpty || selectedImage != nil) ? Color.brand : Color.gray)
            .cornerRadius(4)
            .disabled(vm.chatText.isEmpty && selectedImage == nil)
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
    
    private func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "group_chat_images/\(group.id ?? "unknown")/\(filename).jpg")
        
        isUploadingImage = true
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            isUploadingImage = false
            if let error = error {
                print("Failed to upload image: \(error)")
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }
                if let url = url {
                    vm.handleSend(text: vm.chatText, imageUrl: url.absoluteString)
                    selectedImage = nil
                    vm.chatText = ""
                    dynamicHeight = 32 // Reset height
                }
            }
        }
    }
    
    struct MessageView: View {
        let message: GroupChatMessage
        @State private var user: User?
        
        var body: some View {
            VStack {
                if message.fromId == Auth.auth().currentUser?.uid {
                    HStack {
                        Spacer()
                        messageContent
                    }
                } else {
                    HStack {
                        if let user = user {
                            ProfileView(user: user, radius: 24)
                        }
                        messageContent
                        Spacer()
                    }
                    .onAppear {
                        fetchUser()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        
        private var messageContent: some View {
            VStack(alignment: .leading) {
                if let imageUrl = message.imageUrl {
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200)
                        .cornerRadius(8)
                }
                if !message.text.isEmpty {
                    Text(message.text)
                        .padding()
                        .background(message.fromId == Auth.auth().currentUser?.uid ? Color.brand : Color(.systemGray5))
                        .foregroundColor(message.fromId == Auth.auth().currentUser?.uid ? .white : .black)
                        .cornerRadius(8)
                }
            }
        }
        
        private func fetchUser() {
            Firestore.firestore().collection("users").document(message.fromId).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch user:", error)
                    return
                }
                if let data = snapshot?.data() {
                    do {
                        let user = try snapshot?.data(as: User.self)
                        self.user = user
                    } catch {
                        print("Failed to decode user:", error)
                    }
                }
            }
        }
    }
}

