//import SwiftUI
//import Firebase
//import FirebaseFirestore
//
//class NotificationManager: ObservableObject {
//    @Published var receivedNotifications: [Notification] = []
//    @Published var sentNotifications: [Notification] = []
//    
//
//    
//    func fetchNotifications(for userId: String) {
//        let db = Firestore.firestore()
//        
//        // Fetch received notifications
//        db.collection("notifications")
//            .whereField("toUserId", isEqualTo: userId)
//            .addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("Error fetching received notifications: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                self.receivedNotifications = documents.compactMap { self.createNotification(from: $0) }
//            }
//        
//        // Fetch sent notifications
//        db.collection("notifications")
//            .whereField("fromUserId", isEqualTo: userId)
//            .addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("Error fetching sent notifications: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                self.sentNotifications = documents.compactMap { self.createNotification(from: $0) }
//            }
//    }
//    
//    private func createNotification(from document: QueryDocumentSnapshot) -> Notification? {
//        let data = document.data()
//        return Notification(id: document.documentID,
//                            type: data["type"] as? String ?? "",
//                            fromUserId: data["fromUserId"] as? String ?? "",
//                            toUserId: data["toUserId"] as? String ?? "",
//                            status: data["status"] as? String ?? "",
//                            timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date())
//    }
//}
//
//
//
//struct Notification: Identifiable {
//    let id: String
//    let type: String
//    let fromUserId: String
//    let toUserId: String
//    let status: String
//    let timestamp: Date
//}
//
//struct NotificationView: View {
//    @StateObject private var notificationManager = NotificationManager()
////    @State private var navigationPath = NavigationPath()
//    
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(notificationManager.receivedNotifications) { notification in
//                    if notification.type == "friendRequest" {
//                        FriendRequestNotificationView(notification: notification)
//                    }
//                }
//                
//                
//                ForEach(notificationManager.sentNotifications) { notification in
//                    if notification.type == "friendRequest" {
//                        SentFriendRequestView(notification: notification)
//                    }
//                }
//                
//                
//                
//                
//            }
//            .listStyle(.plain)
//            .navigationBarTitle("알림")
//        }
//        .onAppear {
//            if let userId = Auth.auth().currentUser?.uid {
//                notificationManager.fetchNotifications(for: userId)
//            }
//        }
//    }
//}
//
//
//struct FriendRequestNotificationView: View {
//    let notification: Notification
//    
//    @StateObject private var friendsViewModel = FriendsViewModel()
//
//    
//    var body: some View {
//        HStack {
//            Text("새로운 친구 요청이 있습니다.")
//            Spacer()
//            Button("수락") {
//                acceptFriendRequest(notification: notification)
//            }
//            Button("거절") {
//                rejectFriendRequest(notification: notification)
//            }
//        }
//    }
//    
//    func acceptFriendRequest(notification: Notification) {
//        let db = Firestore.firestore()
//        db.collection("friendRequests").document(notification.id).updateData([
//            "status": "accepted"
//        ]) { error in
//            if let error = error {
//                print("Error accepting friend request: \(error.localizedDescription)")
//            } else {
//                friendsViewModel.addFriend(userId1: notification.toUserId, userId2: notification.fromUserId)
//            }
//        }
//    }
//    
//    func rejectFriendRequest(notification: Notification) {
//        let db = Firestore.firestore()
//        db.collection("friendRequests").document(notification.id).updateData([
//            "status": "rejected"
//        ]) { error in
//            if let error = error {
//                print("Error rejecting friend request: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func addFriend(userId1: String, userId2: String) {
//        let db = Firestore.firestore()
//        db.collection("users").document(userId1).updateData([
//            "friends": FieldValue.arrayUnion([userId2])
//        ])
//        db.collection("users").document(userId2).updateData([
//            "friends": FieldValue.arrayUnion([userId1])
//        ])
//    }
//}
//
//struct SentFriendRequestView: View {
//    let notification: Notification
//    @State private var recipientName: String = ""
//    @State private var profileImageURL: String = ""
//    
//    var body: some View {
//        HStack {
//            UserProfileImage(imageURL: profileImageURL)
//                .frame(width: 40, height: 40)
//            
//            VStack(alignment: .leading) {
//                Text("\(recipientName)에게 친구 요청을 보냈습니다.")
//                    .lineLimit(1)
//                Text(notification.status.capitalized)
//                    .foregroundColor(statusColor(for: notification.status))
//                    .font(.caption)
//            }
//            Spacer()
//        }
//        .onAppear {
//            fetchRecipientInfo()
//        }
//    }
//    
//    func statusColor(for status: String) -> Color {
//        switch status {
//        case "pending":
//            return .gray
//        case "accepted":
//            return .green
//        case "rejected":
//            return .red
//        default:
//            return .gray
//        }
//    }
//    
//    func fetchRecipientInfo() {
//        let db = Firestore.firestore()
//        db.collection("users").document(notification.toUserId).getDocument { (document, error) in
//            
//            if let document = document, document.exists {
//                let data = document.data()
//                self.recipientName = data?["Name"] as? String ?? "Unknown"
//                self.profileImageURL = data?["profile_image"] as? String ?? ""
//                
//                print("Fetching document for user ID: \(notification.toUserId)")
//
//
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
//}
//
//struct UserProfileImage: View {
//    let imageURL: String
//    
//    var body: some View {
//        if let url = URL(string: imageURL) {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                case .success(let image):
//                    image.resizable()
//                         .aspectRatio(contentMode: .fill)
//                         .clipShape(Circle())
//                case .failure:
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundColor(.gray)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//        } else {
//            Image(systemName: "person.circle.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.gray)
//        }
//    }
//}
//
//
//
//#Preview{
//    NotificationView()
//}
