//
//  Group.swift
//  Connected
//
//  Created by 정근호 on 11/14/24.
//

import Foundation

// Model for group information
struct Groups {
    let name: String
    let descriptions: String
    let tags: [String]
    let location: String
    let memberCounts: Int
    let mainImageUrl: String
    
    
}


extension Groups {
    static var MOCK_GROUPS: [Groups] = [
        Groups(name: "러닝모임", descriptions: "광안리 런닝", tags: ["런닝"], location: "남구", memberCounts: 10, mainImageUrl: "https://picsum.photos/200"),
        Groups(name: "독서모임", descriptions: "중도에서 독서하자", tags: ["독서"], location: "대연동", memberCounts: 8, mainImageUrl: "https://picsum.photos/300"),
    ]
}


