//
//  MainMessagesViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/4/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
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
                if user == nil {
                    self.errorMessage = "Failed to fetch current user"
                }
            }
        }
    }
    
    func fetchRecentMessages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        firestoreListener?.remove()
        recentMessages.removeAll()
        
        firestoreListener = Firestore.firestore()
            .collection("recent_messages")
            .document(userId)
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
                
                let messages = querySnapshot?.documents.compactMap { document -> RecentMessage? in
                    do {
                        let message = try document.data(as: RecentMessage.self)
                        print("Decoded RecentMessage: \(message)")
                        return message
                    } catch {
                        print("Failed to decode RecentMessage: \(error)")
                        return nil
                    }
                } ?? []
                
                DispatchQueue.main.async {
                    self.recentMessages = messages
                }
            }
    }
}
