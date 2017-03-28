//
//  User.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation

class User {
    
    //private(set) var username: String? // Currently not needed?
    private(set) var password: String
    private(set) var uid: String
    private(set) var email: String
    
    init(uid: String, email: String, password: String){
        self.uid = uid
        self.email = email
        self.password = password
    }
    
    var userInfo: [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["email"] = email
        dictionary["password"] = password
        return dictionary
    }
}
