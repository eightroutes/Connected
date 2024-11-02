//
//  UserService.swift
//  Connected
//
//  Created by 정근호 on 10/7/24.
//

import Foundation
import Firebase

struct UserService {
    
    static func fetchUser(withUid uid: String) async throws -> User? {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        // Firestore 문서의 JSON 데이터를 User 객체로 디코딩
        return try snapshot.data(as: User.self)

    }
    
    @MainActor
    // static -> UserService initializing을 매번 할 필요없음
    static func fetchAllUsers() async throws -> [User] {
//        var users = [User]()
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
//        let documents = snapshot.documents
//        for doc in documents {
//            print(doc.data())
//            guard let user = try? doc.data(as: User.self) else { return users }
//            users.append(user)
//        }
//        return users
        return snapshot.documents.compactMap({ try? $0.data(as: User.self) })
        

        
    }
}
