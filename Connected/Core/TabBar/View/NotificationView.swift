import SwiftUI
import Firebase
import FirebaseFirestore

class NotificationManager: ObservableObject {
    @Published var receivedNotifications: [Notification] = []
    @Published var sentNotifications: [Notification] = []
    
    func fetchNotifications(for userId: String) {
        let db = Firestore.firestore()
        
        // Fetch received notifications
        db.collection("notifications")
            .whereField("toUserId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching received notifications: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.receivedNotifications = documents.compactMap { self.createNotification(from: $0) }
            }
        
        // Fetch sent notifications
        db.collection("notifications")
            .whereField("fromUserId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching sent notifications: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.sentNotifications = documents.compactMap { self.createNotification(from: $0) }
            }
    }
    
    private func createNotification(from document: QueryDocumentSnapshot) -> Notification? {
        let data = document.data()
        return Notification(id: document.documentID,
                            type: data["type"] as? String ?? "",
                            fromUserId: data["fromUserId"] as? String ?? "",
                            toUserId: data["toUserId"] as? String ?? "",
                            status: data["status"] as? String ?? "",
                            timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date())
    }
}



struct Notification: Identifiable {
    let id: String
    let type: String
    let fromUserId: String
    let toUserId: String
    let status: String
    let timestamp: Date
}

struct NotificationView: View {
    @StateObject private var notificationManager = NotificationManager()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section(header: Text("받은 요청")) {
                    ForEach(notificationManager.receivedNotifications) { notification in
                        if notification.type == "friendRequest" {
                            FriendRequestNotificationView(notification: notification)
                        }
                    }
                }
                
                Section(header: Text("보낸 요청")) {
                    ForEach(notificationManager.sentNotifications) { notification in
                        if notification.type == "friendRequest" {
                            SentFriendRequestView(notification: notification)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle("알림")
        }
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                notificationManager.fetchNotifications(for: userId)
            }
        }
    }
}


struct FriendRequestNotificationView: View {
    let notification: Notification
    
    
    var body: some View {
        HStack {
            Text("새로운 친구 요청이 있습니다.")
            Spacer()
            Button("수락") {
                acceptFriendRequest(notification: notification)
            }
            Button("거절") {
                rejectFriendRequest(notification: notification)
            }
        }
    }
    
    func acceptFriendRequest(notification: Notification) {
        let db = Firestore.firestore()
        db.collection("friendRequests").document(notification.id).updateData([
            "status": "accepted"
        ]) { error in
            if let error = error {
                print("Error accepting friend request: \(error.localizedDescription)")
            } else {
                addFriend(userId1: notification.toUserId, userId2: notification.fromUserId)
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
    let notification: Notification
    
    var body: some View {
        HStack {
            Text("친구 요청을 보냈습니다.")
            Spacer()
            Text(notification.status.capitalized)
                .foregroundColor(statusColor(for: notification.status))
        }
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
