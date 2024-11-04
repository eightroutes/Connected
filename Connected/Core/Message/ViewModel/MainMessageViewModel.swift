//
//  MainMessageViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/4/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var recentMessages = [RecentMessage]()
    
    private var firestoreListener: ListenerRegistration?
    private var firestoreManager = FirestoreManager()
    
    
    init() {
        fetchCurrentUser()
        fetchRecentMessages()
        
    }
    
    private func fetchCurrentUser() {
        firestoreManager.fetchCurrentUser { user in
            DispatchQueue.main.async {
                if let user = user {
                    DispatchQueue.main.async {
                        self.chatUser = ChatUser(user: user)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch current user"
                    }
                }
            }
        }
    }
    
    
    func fetchRecentMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        firestoreListener?.remove()
        recentMessages.removeAll()
        
        firestoreListener = Firestore.firestore()
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch recent messages: \(error)"
                        print("Failed to fetch recent messages:", error)
                    }
                    return
                }
                
                let messages = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: RecentMessage.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self.recentMessages = messages
                }
            }
    }
    
    
}
