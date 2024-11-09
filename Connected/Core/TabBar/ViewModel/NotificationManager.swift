import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct Notification: Identifiable {
    let id: String
    let type: String
    let fromUserId: String
    let toUserId: String
    let status: String
    let timestamp: Date
}

class NotificationManager: ObservableObject {
    @Published var receivedNotifications: [Notification] = []
    @Published var sentNotifications: [Notification] = []
    @Published var sentRecipients: [User] = []
    
    private let db = Firestore.firestore()
    
    func fetchNotifications(for userId: String) {
        // Fetch received notifications
        db.collection("notifications")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("type", isEqualTo: "friendRequest")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching received notifications: \(error.localizedDescription)")
                    return
                }
                
                self.receivedNotifications = querySnapshot?.documents.compactMap { self.createNotification(from: $0) } ?? []
            }
        
        // Fetch sent notifications
        db.collection("notifications")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("type", isEqualTo: "friendRequest")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching sent notifications: \(error.localizedDescription)")
                    return
                }
                
                self.sentNotifications = querySnapshot?.documents.compactMap { self.createNotification(from: $0) } ?? []
                
                // Fetch recipient users
                let toUserIds = self.sentNotifications.map { $0.toUserId }
                self.fetchSentRecipients(userIds: toUserIds)
            }
    }
    
    private func createNotification(from document: QueryDocumentSnapshot) -> Notification? {
        let data = document.data()
        return Notification(
            id: document.documentID,
            type: data["type"] as? String ?? "",
            fromUserId: data["fromUserId"] as? String ?? "",
            toUserId: data["toUserId"] as? String ?? "",
            status: data["status"] as? String ?? "",
            timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    private func fetchSentRecipients(userIds: [String]) {
        guard !userIds.isEmpty else {
            DispatchQueue.main.async {
                self.sentRecipients = []
            }
            return
        }
        
        // Firestore의 whereField in 연산은 최대 10개까지 지원
        // 만약 10개 이상일 경우, 여러 번 쿼리해야 합니다.
        // 여기서는 단순히 10개 이하로 가정하고 구현합니다.
        self.db.collection("users").whereField(FieldPath.documentID(), in: userIds).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching sent recipients: \(error.localizedDescription)")
                return
            }
            
            let users = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
            DispatchQueue.main.async {
                self.sentRecipients = users
            }
        }
    }
}
