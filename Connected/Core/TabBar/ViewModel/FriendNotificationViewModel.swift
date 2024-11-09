import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FriendNotificationViewModel: ObservableObject {
    @Published var sender: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
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
    
    
}
