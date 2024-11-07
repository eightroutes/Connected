//
//  RecentMessage.swift
//  Connected
//
//  Created by 정근호 on 11/4/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct RecentMessage: Identifiable, Decodable{
    @DocumentID var id: String?
    let text: String
    let fromId: String
    let toId: String
    let timestamp: Timestamp
    let user: User

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
        case timestamp
        case user
    }
    
}

