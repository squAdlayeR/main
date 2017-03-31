//
//  DataServiceManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation

class DataServiceManager {
    
    static let instance = DataServiceManager()
    
    private var userAuthenticator = UserAuthenticator.instance
    private var databaseManager = DatabaseManager.instance
    
    func addUserToDatabase(user: User) {
        databaseManager.addUserToDatabase(user: user)
    }
    
    func addRouteToDatabase(route: Route) {
        databaseManager.addRouteToDatabase(route: route)
    }
    
    func createUser(email: String, password: String, completion: AuthenticationCallback?) {
        userAuthenticator.createUser(email: email, password: password, completion: completion)
    }
    
    func signInUser(email: String, password: String, completion: AuthenticationCallback?) {
        userAuthenticator.signInUser(email: email, password: password, completion: completion)
    }
    
    func signOut() {
        userAuthenticator.signOut()
    }
    

}
