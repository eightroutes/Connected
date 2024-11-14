import SwiftUI
import Firebase
import FirebaseFirestore

struct NotificationView: View {
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var friendRequestViewModel = FriendRequestViewModel()
    
    @State var isRequestDefined = false
    
    
//    // 통합된 요청 리스트
//    var combinedNotifications: [CombinedNotification] {
//        let received = notificationManager.receivedNotifications.map { CombinedNotification(notification: $0, type: .received) }
//        let sent = friendRequestViewModel.recipients.map { CombinedNotification(user: $0, type: .sent) }
//        return received + sent
//    }
    
    var body: some View {
        NavigationStack {
            // 받은 요청, 보낸 요청 나누지 말고 통일하기
            VStack(alignment: .leading){
                Text("받은 요청")
                    .font(.headline)
                    .padding([.horizontal,.top])
                Divider()
                    .frame(height: 2)
            }
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(notificationManager.receivedNotifications) { notification in
                        if notification.type == "friendRequest" && notification.status == "pending" {
                            FriendRequestNotificationView(notification: notification, isRequestDefined: $isRequestDefined)
                            // isRequestDefined Binding으로 전달
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            Divider()
                            
                        }
                    }
                }
            }
            VStack(alignment: .leading){
                Text("보낸 요청")
                    .font(.headline)
                    .padding(.horizontal)
                Divider()
                    .frame(height: 2)
            }
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(friendRequestViewModel.recipients) { user in
                        SentFriendRequestView(user: user)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        Divider()
                        
                    }
                }
                .padding(.top)
                
            }
            
            //        NavigationStack {
            //            VStack(alignment: .leading) {
            //                ScrollView {
            //                    ForEach(combinedNotifications) { combined in
            //                        switch combined.type {
            //                            case .received:
            //                                if combined.notification.type == "friendRequest" && combined.notification.status == "pending" {
            //                                    FriendRequestNotificationView(notification: combined.notification, isRequestDefined: $isRequestDefined)
            //                                        .padding(.vertical, 4)
            //                                }
            //                            case .sent:
            //                                SentFriendRequestView(user: combined.user)
            //                                    .padding(.vertical, 4)
            //                        }
            //                    }
            //                }
            //            }
            //
            //
            //        }//NavigationStack
            .navigationBarTitle("알림")
            .onAppear {
                if let userId = Auth.auth().currentUser?.uid {
                    friendRequestViewModel.fetchFriendRequestsSent(by: userId)
                    notificationManager.fetchNotifications(for: userId)
                }
            }
//            .alert(isPresented: Binding<Bool>(
//                get: { !friendRequestViewModel.errorMessage.isEmpty },
//                set: { _ in friendRequestViewModel.errorMessage = "" }
//            )) {
//                Alert(title: Text("오류"), message: Text(friendRequestViewModel.errorMessage), dismissButton: .default(Text("확인")))
//            }
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
    
    @Binding var isRequestDefined: Bool
    
    
    var body: some View {
        HStack {
            HStack {
                if let sender = vm.sender {
                    NavigationLink(destination: ProfileDetail(user: sender)) {
                        ProfileView(user: sender, radius: 40)
                            .padding(.trailing, 4)
                    }
                    
                    Text("\(sender.name ?? "UserName") 님이 친구 요청을 보냈습니다.")
                        .font(.footnote)
                }
            }
            
            
            Spacer()
            
            HStack {
                Button(action:{
                    vm.acceptFriendRequest(notification: notification)
                }) {
                    Text("수락")
                        .foregroundStyle(.brand)
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.brand, lineWidth: 1)
                        )
                        .cornerRadius(30)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action:{
                    vm.rejectFriendRequest(notification: notification)
                }) {
                    Text("거절")
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.red, lineWidth: 1)
                        )
                        .cornerRadius(30)
                        .contentShape(Rectangle())
                }
                
            }//HStack(수락,거절)
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
    
    
}
    
struct SentFriendRequestView: View {
    
    let user: User
    
    var body: some View {
        HStack {
            ProfileView(user: user, radius: 40)
                .padding(.trailing, 4)
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

