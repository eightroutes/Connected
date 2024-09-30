//
//  sampleUser.swift
//  Connected
//
//  Created by 정근호 on 8/16/24.
//

import UIKit



extension UserLocation {
    static var SampleUser: UserLocation {
        UserLocation(
            id: "sample_id",
            name: "John Doe",
            latitude: 37.7749,
            longitude: -122.4194,
            profileImageURL: "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png", 
            profileImage: UIImage(named: "basicProfile")
            // 기타 필요한 속성들...
        )
    }
    
    
}
