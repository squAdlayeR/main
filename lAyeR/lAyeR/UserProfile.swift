//
//  UserProfile.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/1.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import ObjectMapper

class UserProfile: Mappable {
    
    private(set) var username: String = "lAyeRuser"
    private(set) var email: String
    private(set) var avatarRef: String
    private(set) var designedRoutes: [String] = []
    
    init(email: String, avatarRef: String = "profilePlaceholder.png", username: String) {
        self.email = email
        self.avatarRef = avatarRef
        self.username = username
    }
    
    required init?(map: Map) {
        guard let username = map.JSON["username"] as? String,
            let email = map.JSON["email"] as? String,
            let avatarRef = map.JSON["avatarRef"] as? String else {
                return nil
        }
        self.username = username
        self.email = email
        self.avatarRef = avatarRef
        self.designedRoutes = map.JSON["designedRoutes"] as? [String] ?? []
    }
    
    func mapping(map: Map) {
        username <- map["username"]
        email <- map["email"]
        avatarRef <- map["avatarRef"]
        designedRoutes <- map["designedRoutes"]
    }
}
