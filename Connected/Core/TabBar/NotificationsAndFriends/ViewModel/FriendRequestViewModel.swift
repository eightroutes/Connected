import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FriendRequestViewModel: ObservableObject {
    @Published var recipients: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var friends: [String] = []
    
    private let db = Firestore.firestore()
    
    func fetchFriends(for userId: String, completion: @escaping ([String]?) -> Void) {
        db.collection("users").document(userId).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching friends: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "친구 목록을 불러오는 중 오류가 발생했습니다."
                }
                completion(nil)
                return
            }
            guard let data = snapshot?.data(), let friends = data["friends"] as? [String] else {
                print("No data found for user.")
                DispatchQueue.main.async {
                    self.errorMessage = "친구 목록을 불러오는 데 실패했습니다."
                }
                completion([])
                return
            }
            
            DispatchQueue.main.async {
                self.friends = friends
            }
            completion(friends)
        }
    }
    
    func fetchFriendRequestsSent(by userId: String) {
        isLoading = true
        
        fetchFriends(for: userId) { [weak self] friends in
            guard let self = self else { return }
            guard let friends = friends else {
                self.errorMessage = "친구 목록을 불러오는 데 실패했습니다."
                self.isLoading = false
                return
            }
            
            db.collection("notifications")
                .whereField("fromUserId", isEqualTo: userId)
                .whereField("type", isEqualTo: "friendRequest")
                .addSnapshotListener { [weak self] querySnapshot, error in
                    guard let self = self else { return }
                    if let error = error {
                        print("Error fetching sent friend requests: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.errorMessage = "친구 요청을 불러오는 중 오류가 발생했습니다."
                            self.isLoading = false
                        }
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        DispatchQueue.main.async {
                            self.errorMessage = "친구 요청을 불러오는 데 실패했습니다."
                            self.isLoading = false
                        }
                        return
                    }
                    
                    // 친구 요청 보낸 사용자들의 아이디 추출
                    let toUserIds = documents.compactMap { $0.data()["toUserId"] as? String }
                    // 기존에 이미 친구인 유저 필터링
                    let filteredToUserIds = toUserIds.filter {!self.friends.contains($0)}
                    
                    if filteredToUserIds.isEmpty {
                        DispatchQueue.main.async {
                            self.recipients = []
                            self.isLoading = false
                        }
                        return
                    }
                    
                    //                // Firestore의 whereField in 연산은 최대 10개까지 지원
                    //                // 만약 10개 이상일 경우, 여러 번 쿼리해야 합니다.
                    //                // 여기서는 단순히 10개 이하로 가정하고 구현합니다.
                    //                self.db.collection("users").whereField(FieldPath.documentID(), in: toUserIds).getDocuments { snapshot, error in
                    //                    if let error = error {
                    //                        print("Error fetching recipients: \(error.localizedDescription)")
                    //                        self.errorMessage = "수신자를 불러오는 중 오류가 발생했습니다."
                    //                        self.isLoading = false
                    //                        return
                    //                    }
                    //
                    //                    let users = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
                    //                    DispatchQueue.main.async {
                    //                        self.recipients = users
                    //                        self.isLoading = false
                    //                    }
                    //                }
                    
                    // Firestore의 'in' 쿼리는 최대 10개까지 지원하므로, 10개 이하로 나눕니다
                    let batches = filteredToUserIds.chunked(into: 10)
                    var fetchedUsers: [User] = []
                    let dispatchGroup = DispatchGroup()
                    
                    for batch in batches {
                        dispatchGroup.enter()
                        self.db.collection("users").whereField(FieldPath.documentID(), in: batch).getDocuments { snapshot, error in
                            if let error = error {
                                print("Error fetching recipients: \(error.localizedDescription)")
                                DispatchQueue.main.async {
                                    self.errorMessage = "수신자를 불러오는 중 오류가 발생했습니다."
                                }
                            } else {
                                let users = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
                                fetchedUsers.append(contentsOf: users)
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        self.recipients = fetchedUsers
                        self.isLoading = false
                    }
                }
            
        }
    }
}

// 배열을 청크로 나누기 위함
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        var currentChunk: [Element] = []
        for element in self {
            currentChunk.append(element)
            if currentChunk.count == size {
                chunks.append(currentChunk)
                currentChunk = []
            }
        }
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        return chunks
    }
}
