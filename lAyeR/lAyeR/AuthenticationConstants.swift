//
//  LoginRegisterConstants.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

struct AuthenticationConstants {
    
    static let minimumPasswordLength: Int = 6
    static let maximumPasswordLength: Int = 12
    static let fbPermissions: [String] = ["public_profile",
                                          "email",
                                          "user_friends"]
}
