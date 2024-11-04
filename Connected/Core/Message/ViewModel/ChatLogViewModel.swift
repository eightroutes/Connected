//
//  ChatLogViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/4/24.
//
import SwiftUI
import Foundation
import Firebase

// ObservableObject는 SwiftUI에서 사용되는 프로토콜로, 뷰 모델이 SwiftUI 뷰와 데이터를 바인딩할 수 있도록 합니다. ObservableObject를 사용하면 @Published 속성의 변화가 있을 때 SwiftUI 뷰가 자동으로 업데이트됩니다.
class ChatLogViewModel: ObservableObject {
    
    // @Published는 뷰 모델의 상태 변화를 SwiftUI 뷰에 자동으로 반영.
    // 데이터의 변화에 따라 뷰를 수동으로 업데이트할 필요 없이, 데이터 바인딩을 통해 뷰가 자동으로 변경.
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
//    @ObservedObject var vm: MainMessagesViewModel
    
    var chatUser: ChatUser?
    
    var currentUserName: String = ""
    var currentUserProfileImageUrl: String = ""
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchCurrentUser()
        fetchMessages()
    }
    
    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            self.currentUserName = data["name"] as? String ?? ""
            self.currentUserProfileImageUrl = data["profileImageUrl"] as? String ?? ""
        }
    }
    
    var firestoreListner: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListner?.remove()
        chatMessages.removeAll()
        Firestore.firestore()
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
        //            .addSnapshotListener는 Firebase Firestore에서 제공하는 메서드로, 실시간 데이터 변경을 감지하고 처리하는 데 사용됩니다
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                // documentChanges - 이 스냅샷에서 변경된 모든 문서의 목록을 배열로 제공
//                querySnapshot?.documentChanges.forEach({ change in
//                    if change.type == .added {
//                        let data = change.document.data()
//                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
//
//                    }
//                })
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            // Decode the document into a ChatMessage instance
                            if let chatMessage = try change.document.data(as: ChatMessage?.self) {
                                self.chatMessages.append(chatMessage)
                                print("Appending chatMessage in ChatLogView: \(Date())")
                            }
                        } catch {
                            print("Error decoding ChatMessage: \(error)")
                            self.errorMessage = "Error decoding message: \(error.localizedDescription)"
                        }
                    }
                })

                
                DispatchQueue.main.async {
                    self.count += 1
                }
                
                //                querySnapshot?.documents.forEach({ queryDocumentSnapshot in
                //                    let data = queryDocumentSnapshot.data()
                //                    let docId = queryDocumentSnapshot.documentID
                //                    self.chatMessages.append(.init(documentId: docId, data: data))
                //                })
            }
    }
    
    func handleSend(text: String) {
        print(chatText)
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        
        // 현재 유저
        let document = Firestore.firestore().collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        // 받는 유저
        let recipientMessageDocument = Firestore.firestore().collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Recipient saved message as well")
            
        }
    }
    
    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        
        
        // Data for the current user's recent messages
        let data = [
          "timestamp": Timestamp(),
          "text": self.chatText,
          "fromId": uid,
          "toId": toId,
          "profileImageUrl": chatUser.profileImageUrl,
          "email": chatUser.email,
          "name": chatUser.name  // Include recipient's name
        ] as [String: Any]
        
        let document = Firestore.firestore()
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        // save another very similar dictionary for the recipient of this message
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        // Data for the recipient's recent messages
       let recipientData = [
           "timestamp": Timestamp(),
           "text": self.chatText,
           "fromId": uid,
           "toId": toId,
           "profileImageUrl": self.currentUserProfileImageUrl,
           "email": Auth.auth().currentUser?.email ?? "",
           "name": self.currentUserName  // Include sender's name
       ] as [String: Any]

       let recipientDocument = Firestore.firestore()
           .collection("recent_messages")
           .document(toId)
           .collection("messages")
           .document(uid)

       recipientDocument.setData(recipientData) { error in
           if let error = error {
               self.errorMessage = "Failed to save recipient's recent message: \(error)"
               print("Failed to save recipient's recent message: \(error)")
               return
           }
       }
    }
    
    @Published var count = 0
}
