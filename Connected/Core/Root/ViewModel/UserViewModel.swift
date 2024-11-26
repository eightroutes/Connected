//
//  UserViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/26/24.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var hasImages: Bool? = nil
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration? // 리스너를 추가하여 유저 문서의 변경 사항을 실시간으로 감지
    
    func startListening(userId: String) {
        listener = db.collection("users").document(userId).addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data()
                if let otherImages = data?["other_images"] as? [String], !otherImages.isEmpty {
                    DispatchQueue.main.async {
                        self.hasImages = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.hasImages = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.hasImages = false
                }
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
}

//import Foundation
//import FirebaseFirestore
//
//class UserViewModel: ObservableObject {
//    @Published var hasImages: Bool? = nil
//    private let db = Firestore.firestore()
//    
//    func checkForOtherImages(userId: String) {
//        let document = db.collection("users").document(userId)
//        document.getDocument { [weak self] (document, error) in
//            if let document = document, document.exists {
//                let data = document.data()
//                if let otherImages = data?["other_images"] as? [String], !otherImages.isEmpty {
//                    DispatchQueue.main.async {
//                        self?.hasImages = true
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        self?.hasImages = false
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self?.hasImages = false
//                }
//            }
//        }
//    }
//}
