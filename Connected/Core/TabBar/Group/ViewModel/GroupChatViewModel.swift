import SwiftUI
import Foundation
import Firebase
import FirebaseFirestoreSwift

class GroupChatViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [GroupChatMessage]()
    @Published var count = 0
    
    var group: Groups // 그룹 정보
    
    var currentUserId: String = ""
    var currentUserName: String = ""
    var currentUserProfileImageUrl: String = ""
    var currentUserEmail: String = ""
    
    var firestoreListener: ListenerRegistration?
    
    init(group: Groups) {
        self.group = group
        fetchCurrentUser()
        fetchMessages()
    }
    
    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.currentUserId = uid
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            self.currentUserName = data["Name"] as? String ?? ""
            self.currentUserProfileImageUrl = data["profile_image"] as? String ?? ""
            self.currentUserEmail = data["email"] as? String ?? ""
        }
    }
    
    func fetchMessages() {
        let groupId = group.id ?? ""
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = Firestore.firestore()
            .collection("group_messages")
            .document(groupId)
            .collection("messages")
            .order(by: FirebaseConstants.timestamp, descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    self?.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let chatMessage = try change.document.data(as: GroupChatMessage.self)
                            self?.chatMessages.append(chatMessage)
                            print("Appending chatMessage in GroupChatView: \(Date())")
                        } catch {
                            print("Error decoding ChatMessage: \(error)")
                            self?.errorMessage = "Error decoding message: \(error.localizedDescription)"
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self?.count += 1
                }
            }
    }
    
    func handleSend(text: String) {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        let groupId = group.id ?? ""
        
        let messageData: [String: Any] = [
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.text: text,
            FirebaseConstants.timestamp: Timestamp(),
            "userName": currentUserName,
            "userProfileImageUrl": currentUserProfileImageUrl
        ]
        
        let document = Firestore.firestore()
            .collection("group_messages")
            .document(groupId)
            .collection("messages")
            .document()
        
        document.setData(messageData) { [weak self] error in
            if let error = error {
                print("Failed to save message into Firestore: \(error)")
                self?.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Successfully saved group message")
            DispatchQueue.main.async {
                self?.chatText = ""
                self?.count += 1
            }
            self?.persistRecentGroupMessage(text: text)
        }
    }
    
    private func persistRecentGroupMessage(text: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let groupId = group.id ?? ""
        
        let recentMessageData: [String: Any] = [
            "text": text,
            "fromId": currentUserId,
            "timestamp": Timestamp(),
            "groupId": groupId,
            "groupName": group.name,
            "groupImageUrl": group.mainImageUrl
        ]
        
        // 모든 그룹 멤버의 recent_messages에 저장
        for memberId in group.members {
            Firestore.firestore()
                .collection("recent_group_messages")
                .document(memberId)
                .collection("groups")
                .document(groupId)
                .setData(recentMessageData) { error in
                    if let error = error {
                        print("Failed to save recent group message for member \(memberId): \(error)")
                        return
                    }
                    print("Successfully saved recent group message for member \(memberId)")
                }
        }
    }
}
