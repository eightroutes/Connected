//
//  RecentMessage.swift
//  Connected
//
//  Created by 정근호 on 11/4/24.
//

import Foundation
import Firebase
import FirebaseFirestore


struct RecentMessage: Identifiable, Decodable {
    @DocumentID var id: String?
    let text: String
    let fromId: String
    let toId: String
    let email: String
    let profileImageUrl: String
    let name: String
    let timestamp: Timestamp

    var timeAgo: String {
        let date = timestamp.dateValue()
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case fromId
        case toId
        case email
        case profileImageUrl = "profile_image" // Map to Firestore key
        case name = "Name"                     // Map to Firestore key
        case timestamp
    }
}

