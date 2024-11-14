//
//  CombinedNotification.swift
//  Connected
//
//  Created by 정근호 on 11/9/24.
//

import Foundation

struct CombinedNotification: Identifiable {
    let id: String
    let type: NotificationType
    
    // 받은 요청인 경우
    let notification: Notification?
    
    // 보낸 요청인 경우
    let user: User?
    
    init(notification: Notification, type: NotificationType) {
        self.id = notification.id
        self.type = type
        self.notification = notification
        self.user = nil
    }
    
    init(user: User, type: NotificationType) {
        self.id = user.id ?? UUID().uuidString
        self.type = type
        self.user = user
        self.notification = nil
    }
}

enum NotificationType {
    case received
    case sent
}
