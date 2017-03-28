//
//  User.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper

class User: Mappable {
    
    //private(set) var username: String? // Currently not needed?
    private(set) var password: String
    private(set) var uid: String
    private(set) var email: String
    
    init(uid: String, email: String, password: String){
        self.uid = uid
        self.email = email
        self.password = password
    }
    
    required init?(map: Map) {
        guard let uid = map.JSON["uid"] as? String,
            let email = map.JSON["email"] as? String,
            let password = map.JSON["password"] as? String else {
                return nil
        }
        self.uid = uid
        self.email = email
        self.password = password
    }
    
    func mapping(map: Map) {
        uid <- map["uid"]
        email <- map["email"]
        password <- map["password"]
    }
}
