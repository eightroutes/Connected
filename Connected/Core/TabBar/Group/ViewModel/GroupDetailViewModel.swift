import Foundation
import FirebaseFirestore
import FirebaseAuth

class GroupDetailViewModel: ObservableObject {
    @Published var isMember: Bool = false
    @Published var errorMessage: String? = nil
//    @Published var isJoining: Bool = false

    private var db = Firestore.firestore()

    func checkMembership(for group: Groups) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.isMember = false
            self.errorMessage = "사용자가 인증되지 않았습니다."
            return
        }

        // Firestore에서 그룹의 멤버 목록을 확인
        db.collection("groups").document(group.id!).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "멤버 확인 중 오류 발생: \(error.localizedDescription)"
                    self?.isMember = false
                    return
                }

                if let data = snapshot?.data(), let members = data["members"] as? [String] {
                    self?.isMember = members.contains(currentUserId)
                } else {
                    self?.isMember = false
                }
            }
        }
    }

    func joinGroup(for group: Groups, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 인증되지 않았습니다."]))
            return
        }

        guard let groupId = group.id else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 그룹 ID"]))
            return
        }

        let groupRef = db.collection("groups").document(groupId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let groupDocument: DocumentSnapshot
            do {
                try groupDocument = transaction.getDocument(groupRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var members = groupDocument.data()?["members"] as? [String] else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "멤버 정보를 가져올 수 없습니다."])
                errorPointer?.pointee = error
                return nil
            }

            if members.contains(currentUserId) {
                // 이미 멤버인 경우
                return nil
            }

            members.append(currentUserId)
            transaction.updateData(["members": members, "memberCounts": members.count], forDocument: groupRef)

            return nil
        }) { [weak self] (object, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "그룹 참가 중 오류 발생: \(error.localizedDescription)"
                    completion(false, error)
                }
            } else {
                DispatchQueue.main.async {
                    self?.isMember = true
                    completion(true, nil)
                }
            }
        }
    }
}
