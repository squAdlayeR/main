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
    
    var currentUserID: String? {
        return userAuthenticator.currentUser?.uid
    }
    
    func addUserProfileToDatabase(uid: String, profile: UserProfile) {
        databaseManager.addUserProfileToDatabase(uid: uid, userProfile: profile)
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
    
    func retrieveUserProfile(completion: @escaping (_ userProfile: UserProfile) -> ()) {
        guard let uid = userAuthenticator.currentUser?.uid else { return }
        if let userProfile = databaseManager.currentUserProfile {
            completion(userProfile)
            return
        }
        databaseManager.getUserProfile(uid: uid, completion: completion)
    }

}
