//
//  FriendsViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/8/24.
//


import FirebaseFirestore
import FirebaseAuth

enum FriendStatus {
    case notFriends        // 친구가 아님
    case requestSent       // 친구 요청을 보낸 상태
    case friends           // 이미 친구인 상태
}


class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var errorMessage: String?
    @Published var friendStatus: FriendStatus = .notFriends
    @Published var sentFriendRequests: Set<String> = []


    @Published var isFriend: Bool = false
    
    private let db = Firestore.firestore()
    
    func sendFriendRequest(to userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("friendRequests").addDocument(data: [
            "fromUserId": currentUserId,
            "toUserId": userId,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error sending friend request: \(error.localizedDescription)")
                // 사용자에게 에러 알림 표시
            } else {
                print("Friend request sent successfully")
                DispatchQueue.main.async {
                    self.sentFriendRequests.insert(userId)
                    self.friendStatus = .requestSent 
                }
                
                // 알림 생성
                db.collection("notifications").addDocument(data: [
                    "type": "friendRequest",
                    "fromUserId": currentUserId,
                    "toUserId": userId,
                    "status": "pending",
                    "timestamp": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Error creating notification: \(error.localizedDescription)")
                        // 사용자에게 에러 알림 표시
                    }
                }
            }
        }
    }
    
    func loadSentFriendRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("friendRequests")
            .whereField("fromUserId", isEqualTo: currentUserId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching sent friend requests: \(error.localizedDescription)")
                    return
                }
                
                let sentRequests = querySnapshot?.documents.compactMap { $0.data()["toUserId"] as? String } ?? []
                DispatchQueue.main.async {
                    self.sentFriendRequests = Set(sentRequests)
                }
            }
    }
    
    
    func checkFriendStatus(currentUserId: String?, profileUserId: String) {
        guard let currentUserId = currentUserId else { return }
                
        
        db.collection("users").document(currentUserId).collection("friends").document(profileUserId).getDocument { snapshot, error in
                if let snapshot = snapshot, snapshot.exists {
                    DispatchQueue.main.async {
                        self.friendStatus = .friends
                    }
                } else {
                    // 친구 요청을 보냈는지 확인
                    self.db.collection("friendRequests").whereField("fromUserId", isEqualTo: currentUserId).whereField("toUserId", isEqualTo: profileUserId).getDocuments { querySnapshot, error in
                        if let documents = querySnapshot?.documents, !documents.isEmpty {
                            DispatchQueue.main.async {
                                self.friendStatus = .requestSent
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.friendStatus = .notFriends
                            }
                        }
                    }
                }
            }
        }
    


    
    func fetchFriends() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUserId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching current user: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = "친구 목록을 불러오는 중 오류가 발생했습니다."
                }
                return
            }
            
            guard let data = document?.data(),
                  let friendIds = data["friends"] as? [String] else {
                DispatchQueue.main.async {
                    self.friends = []
                }
                return
            }
            
            self.friends = []
            let dispatchGroup = DispatchGroup()
            
            for friendId in friendIds {
                dispatchGroup.enter()
                self.db.collection("users").document(friendId).getDocument { friendDoc, error in
                    defer { dispatchGroup.leave() }
                    if let error = error {
                        print("Error fetching friend: \(error.localizedDescription)")
                        return
                    }
                    
                    if let friendData = friendDoc?.data(),
                       let friend = try? friendDoc?.data(as: User.self) {
                        DispatchQueue.main.async {
                            self.friends.append(friend)
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // 모든 친구 데이터 로드 완료
            }
        }
    }
    
    
    // Add a friend to both users' friends list
    func addFriend(userId1: String, userId2: String) {
        let group = DispatchGroup()
        var friendError: String?
        
        // Add user2 to user1's friends list
        group.enter()
        db.collection("users").document(userId1).updateData([
            "friends": FieldValue.arrayUnion([userId2])
        ]) { error in
            if let error = error {
                friendError = error.localizedDescription
            }
            group.leave()
        }
        
        // Add user1 to user2's friends list
        group.enter()
        db.collection("users").document(userId2).updateData([
            "friends": FieldValue.arrayUnion([userId1])
        ]) { error in
            if let error = error {
                friendError = error.localizedDescription
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let friendError = friendError {
                self.errorMessage = friendError
            } else {
                self.fetchFriends() // Refresh friends list after adding a friend
            }
        }
    }
    
    func removeFriend(_ friend: User) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        let friendId = friend.id
        let userRef = db.collection("users").document(currentUserId)
        let friendRef = db.collection("users").document(friendId)
        
        db.runTransaction { transaction, errorPointer in
            do {
                let userDocument = try transaction.getDocument(userRef)
                var userFriends = userDocument.data()?["friends"] as? [String] ?? []
                if let index = userFriends.firstIndex(of: friendId) {
                    userFriends.remove(at: index)
                    transaction.updateData(["friends": userFriends], forDocument: userRef)
                }
                
                let friendDocument = try transaction.getDocument(friendRef)
                var friendFriends = friendDocument.data()?["friends"] as? [String] ?? []
                if let index = friendFriends.firstIndex(of: currentUserId) {
                    friendFriends.remove(at: index)
                    transaction.updateData(["friends": friendFriends], forDocument: friendRef)
                }
                
                return nil
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
        } completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.friends.removeAll { $0.id == friendId }
                }
                print("Friend successfully removed.")
            }
        }
    }
}
