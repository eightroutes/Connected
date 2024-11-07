import SwiftUI
import Foundation
import Firebase
import FirebaseFirestoreSwift

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var count = 0  // count 변수를 선언하여 에러 방지
    
    var user: User?
    
    var currentUserName: String = ""
    var currentUserProfileImageUrl: String = ""
    var currentUserId: String = ""
    var currentUserEmail: String = ""
    
    init(user: User?) {
        self.user = user
        
        fetchCurrentUser()
        fetchMessages()
    }
    
    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.currentUserId = uid  // currentUserId 설정
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            self.currentUserName = data["Name"] as? String ?? ""
            self.currentUserProfileImageUrl = data["profile_image"] as? String ?? ""
            self.currentUserEmail = data["email"] as? String ?? ""
            // 필드 이름이 다르다면 여기를 수정하세요.
        }
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = user?.id else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = Firestore.firestore()
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let chatMessage = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(chatMessage)
                            print("Appending chatMessage in ChatLogView: \(Date())")
                        } catch {
                            print("Error decoding ChatMessage: \(error)")
                            self.errorMessage = "Error decoding message: \(error.localizedDescription)"
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    func handleSend(text: String) {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = user?.id else { return }
        
        let messageData: [String: Any] = [
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.text: text,
            FirebaseConstants.timestamp: Timestamp()
        ]
        
        let document = Firestore.firestore().collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        document.setData(messageData) { error in
            if let error = error {
                print("Failed to save message into Firestore: \(error)")
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Successfully saved current user sending message")
            
            self.chatText = ""
            self.count += 1
            
            // 최근 메시지 저장
            self.persistRecentMessage(text: text, toId: toId)
        }
        
        // 상대방의 메시지 저장
        let recipientMessageDocument = Firestore.firestore().collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print("Failed to save message into Firestore: \(error)")
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage(text: String, toId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let user = user else { return }

        // 현재 유저의 최근 메시지 데이터 (상대방의 정보를 포함)
        let recentMessageData: [String: Any] = [
            "text": text,
            "fromId": uid,
            "toId": toId,
            "timestamp": Timestamp(),
            "user": [
                "id": user.id,
                "Name": user.name ?? "",
                "email": user.email ?? "",
                "profile_image": user.profileImageUrl ?? ""
            ]
        ]

        // 현재 유저의 recent_messages에 저장
        Firestore.firestore()
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
            .setData(recentMessageData) { error in
                if let error = error {
                    print("Failed to save recent message: \(error)")
                    return
                }
                print("Successfully saved recent message for current user")
            }
        
        // 상대방의 최근 메시지 데이터 (현재 유저의 정보를 포함)
        let recipientRecentMessageData: [String: Any] = [
            "text": text,
            "fromId": uid,
            "toId": toId,
            "timestamp": Timestamp(),
            "user": [
                "id": uid,
                "Name": self.currentUserName,
                "email": self.currentUserEmail,
                "profile_image": self.currentUserProfileImageUrl
            ]
        ]

        // 상대방의 recent_messages에 저장
        Firestore.firestore()
            .collection("recent_messages")
            .document(toId)
            .collection("messages")
            .document(uid)
            .setData(recipientRecentMessageData) { error in
                if let error = error {
                    print("Failed to save recent message for recipient: \(error)")
                    return
                }
                print("Successfully saved recent message for recipient")
            }

    }

}
