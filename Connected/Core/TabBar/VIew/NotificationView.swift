import SwiftUI
import Firebase
import FirebaseFirestore

struct NotificationView: View {
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var friendRequestViewModel = FriendRequestViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("받은 요청")) {
                    ForEach(notificationManager.receivedNotifications) { notification in
                        if notification.type == "friendRequest" && notification.status == "pending" {
                            FriendRequestNotificationView(notification: notification)
                        }
                    }
                }
                
                Section(header: Text("보낸 요청")) {
                    ForEach(friendRequestViewModel.recipients) { user in
                        SentFriendRequestView(user: user)

                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitle("알림")
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                notificationManager.fetchNotifications(for: userId)
                friendRequestViewModel.fetchFriendRequestsSent(by: userId)
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { !friendRequestViewModel.errorMessage.isEmpty },
            set: { _ in friendRequestViewModel.errorMessage = "" }
        )) {
            Alert(title: Text("오류"), message: Text(friendRequestViewModel.errorMessage), dismissButton: .default(Text("확인")))
        }
    }
}

#Preview {
    NotificationView()
}

struct FriendRequestNotificationView: View {
    let notification: Notification
    
    @StateObject private var vm = FriendNotificationViewModel()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        HStack {
            if let sender = vm.sender {
                ProfileView(user: sender, radius: 40)
                    .onTapGesture {
                        ProfileDetail(user: sender)
                    }
                Text("\(sender.name ?? "UserName") 님이 친구 요청을 보냈습니다.")
                    .font(.footnote)
            }
            
            Spacer()
            
            Button(action:{
                acceptFriendRequest(notification: notification)
            }) {
                Text("수락")
                    .foregroundStyle(.brand)
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .font(.footnote)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.brand, lineWidth: 1)
                    )
                    .cornerRadius(30)
            }
            .buttonStyle(.plain)
            
            Button(action:{
                rejectFriendRequest(notification: notification)
            }) {
                Text("거절")
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.red, lineWidth: 1)
                    )
                    .cornerRadius(30)
            }
            .buttonStyle(.plain)
        }//HStack
        .padding(.vertical, 8) // 상하 여백 추가
        .onAppear {
            vm.fetchSender(userId: notification.fromUserId)
        }
        .alert(isPresented: Binding<Bool>(
            get: { !vm.errorMessage.isEmpty },
            set: { _ in vm.errorMessage = "" }
        )) {
            Alert(title: Text("오류"), message: Text(vm.errorMessage), dismissButton: .default(Text("확인")))
        }
    }
    
    func acceptFriendRequest(notification: Notification) {
        let db = Firestore.firestore()
        db.collection("friendRequests").document(notification.id).updateData([
            "status": "accepted"
        ]) { error in
            if let error = error {
                print("Error accepting friend request: \(error.localizedDescription)")
                alertMessage = "친구 요청을 수락하는 중 오류가 발생했습니다."
                showAlert = true
            } else {
                addFriend(userId1: notification.toUserId, userId2: notification.fromUserId)
                alertMessage = "친구 요청이 수락되었습니다."
                showAlert = true

            }
        }
    }
    
    func rejectFriendRequest(notification: Notification) {
        let db = Firestore.firestore()
        db.collection("friendRequests").document(notification.id).updateData([
            "status": "rejected"
        ]) { error in
            if let error = error {
                print("Error rejecting friend request: \(error.localizedDescription)")
                alertMessage = "친구 요청을 거절하는 중 오류가 발생했습니다."
                showAlert = true
            } else {
                alertMessage = "친구 요청이 거절되었습니다."
                showAlert = true
            }
        }
    }
    
    func addFriend(userId1: String, userId2: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId1).updateData([
            "friends": FieldValue.arrayUnion([userId2])
        ])
        db.collection("users").document(userId2).updateData([
            "friends": FieldValue.arrayUnion([userId1])
        ])
    }
}

struct SentFriendRequestView: View {

    let user: User
    
    var body: some View {
        HStack {
           ProfileView(user: user, radius: 40)
           Text(user.name ?? "UserName")
                .font(.footnote)
            
           Spacer()
            
           Text("요청 보냄")
               .foregroundColor(.gray)
               .font(.footnote)
       }
       .padding(.vertical, 8)
    }
    
    func statusColor(for status: String) -> Color {
        switch status {
        case "pending":
            return .orange
        case "accepted":
            return .green
        case "rejected":
            return .red
        default:
            return .gray
        }
    }
}
