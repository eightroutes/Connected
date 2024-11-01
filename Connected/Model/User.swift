//
//  UserLocation.swift
//  Connected
//
//  Created by 정근호 on 8/17/24.
//

import Foundation
import FirebaseAuth

// 유저 id, 위치, 프로필 등
struct User: Identifiable, Codable, Hashable  {
    var id: String
    var name: String?
    var gender: String?
    var interests: [String]?
    var selectedColor: String?
    var selectedMBTI: String?
    var musicGenres: [String]?
    var movieGenres: [String]?
    var profileImageUrl: String?
    var otherImagesUrl: [String]?
    var latitude: Double?
    var longitude: Double?
    var email: String?
    var age: Int?
    var birthday: String?

    
    var isCurrentUser: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return currentUid == id
        
    }
    

}

enum CodingKeys: String, CodingKey {
        case id
        case name = "Name"
        case email = "email"
        case profileImageUrl = "profile_image"
        case selectedMBTI = "MBTI"
        case selectedColor = "Color"
        case interests = "Interests"
        case musicGenres = "Music"
        case movieGenres = "Movie"
        case birthday = "Birthday"
        case otherImageUrl = "other_images"
        case latitude = "latitude"
        case longitude = "longitude"
    
}


// 가짜 유저 목록
// profileImageUrl - https://pravatar.cc/
extension User {
    static var MOCK_USERS: [User] = [
        .init(id: NSUUID().uuidString, name: "Kevin", gender: "male", interests: ["영화","헬스"], selectedColor: "검은색", selectedMBTI: "intp", musicGenres: ["POP", "Synthwave"], movieGenres: ["스릴러", "판타지"], profileImageUrl: "https://i.pravatar.cc/300", latitude: 35.137662, longitude: 129.103978, email: "kevin@gmail.com"),
        .init(id: NSUUID().uuidString, name: "Karen", gender: "female", interests: ["힙합","헬스"], selectedColor: "보라색", selectedMBTI: "estp", musicGenres: ["HipHop", "Synthwave"], movieGenres: ["스릴러", "뮤지컬"], profileImageUrl: nil, latitude: 34.137662, longitude: 125.103978, email: "karen@gmail.com"),
        .init(id: NSUUID().uuidString, name: "David", gender: "male", interests: ["축구","야구"], selectedColor: "빨간색", selectedMBTI: "entj", musicGenres: ["POP", "EDM"], movieGenres: ["액선", "스릴러"], profileImageUrl: nil, latitude: 33.137662, longitude: 127.103978, email: "david@gmail.com"),
        .init(id: NSUUID().uuidString, name: "Jane", gender: "female", interests: ["주식","창업"], selectedColor: "회색", selectedMBTI: "infj", musicGenres: ["POP", "R&B"], movieGenres: ["로맨스", "판타지"], profileImageUrl: nil, latitude: 36.137662, longitude: 128.103978, email: "jane@gmail.com")
    ]
}
