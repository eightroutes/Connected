//
//  UserLocation.swift
//  Connected
//
//  Created by 정근호 on 8/17/24.
//

import UIKit

// 유저 id, 위치, 프로필 등
struct User: Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let interests: [String]
    let selectedColor: String
    let selectedMBTI: String
    let musicGenres: [String]
    let movieGenres: [String]
    let profileImageURL: String
    let profileImage: UIImage?
}

