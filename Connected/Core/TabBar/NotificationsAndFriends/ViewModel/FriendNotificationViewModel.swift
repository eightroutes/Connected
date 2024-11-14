import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FriendNotificationViewModel: ObservableObject {
    @Published var sender: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published private var showAlert = false
    @Published private var alertMessage = ""
    @Published var isRequestDefined = false
    
    private let db = Firestore.firestore()
    
    func fetchSender(userId: String) {
        isLoading = true
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Error fetching sender: \(error.localizedDescription)")
                self.errorMessage = "보낸 사용자를 불러오는 중 오류가 발생했습니다."
                return
            }
            
            if let user = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async {
                    self.sender = user
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "사용자 데이터를 불러오는 데 실패했습니다."
                }
            }
        }
    }
    
    func acceptFriendRequest(notification: Notification) {
        let db = Firestore.firestore()
        db.collection("notifications").document(notification.id).updateData([
            "status": "accepted"
        ]) { error in
            if let error = error {
                print("Error accepting friend request: \(error.localizedDescription)")
                self.alertMessage = "친구 요청을 수락하는 중 오류가 발생했습니다."
                self.showAlert = true
            } else {
                self.addFriend(userId1: notification.toUserId, userId2: notification.fromUserId)
                self.alertMessage = "친구 요청이 수락되었습니다."
                self.showAlert = true
                self.isRequestDefined = true

            }
        }
    }
    
    func rejectFriendRequest(notification: Notification) {
        let db = Firestore.firestore()
        db.collection("notifications").document(notification.id).updateData([
            "status": "rejected"
        ]) { error in
            if let error = error {
                print("Error rejecting friend request: \(error.localizedDescription)")
                self.alertMessage = "친구 요청을 거절하는 중 오류가 발생했습니다."
                self.showAlert = true
            } else {
                self.alertMessage = "친구 요청이 거절되었습니다."
                self.showAlert = true
                self.isRequestDefined = true
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
