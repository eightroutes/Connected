import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FriendRequestViewModel: ObservableObject {
    @Published var recipients: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let db = Firestore.firestore()
    
    func fetchFriendRequestsSent(by userId: String) {
        isLoading = true
        db.collection("notifications")
            .whereField("fromUserId", isEqualTo: userId)
            .whereField("type", isEqualTo: "friendRequest")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching sent friend requests: \(error.localizedDescription)")
                    self.errorMessage = "친구 요청을 불러오는 중 오류가 발생했습니다."
                    self.isLoading = false
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.errorMessage = "친구 요청을 불러오는 데 실패했습니다."
                    self.isLoading = false
                    return
                }
                
                let toUserIds = documents.compactMap { $0.data()["toUserId"] as? String }
                
                if toUserIds.isEmpty {
                    DispatchQueue.main.async {
                        self.recipients = []
                        self.isLoading = false
                    }
                    return
                }
                
                // Firestore의 whereField in 연산은 최대 10개까지 지원
                // 만약 10개 이상일 경우, 여러 번 쿼리해야 합니다.
                // 여기서는 단순히 10개 이하로 가정하고 구현합니다.
                self.db.collection("users").whereField(FieldPath.documentID(), in: toUserIds).getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching recipients: \(error.localizedDescription)")
                        self.errorMessage = "수신자를 불러오는 중 오류가 발생했습니다."
                        self.isLoading = false
                        return
                    }
                    
                    let users = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
                    DispatchQueue.main.async {
                        self.recipients = users
                        self.isLoading = false
                    }
                }
            }
    }
    
    
}
