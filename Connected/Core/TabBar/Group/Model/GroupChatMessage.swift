//
//  GroupChatMessage.swift
//  Connected
//
//  Created by 정근호 on 11/18/24.
//


import Foundation
import FirebaseFirestore

struct GroupChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let fromId: String
    let text: String
    let timestamp: Date
    let userName: String
    let userProfileImageUrl: String
    let imageUrl: String?

}
