//
//  DatabaseManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper
import FirebaseDatabase

class DatabaseManager {
    
    static let instance = DatabaseManager()
    private(set) var currentUserProfile: UserProfile?
    
    func addUserToDatabase(user: User) {
        FIRDatabase.database().reference().child("users").child(user.uid).setValue(user.toJSON())
    }
    
    func addUserProfileToDatabase(uid: String, userProfile: UserProfile) {
        FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
    }
    
    func updateUserProfile(uid: String, userProfile: UserProfile) {
        FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
    }
    
    func addRouteToDatabase(route: Route) {
        FIRDatabase.database().reference().child("routes").child(route.name).setValue(route.toJSON())
    }
    
    func removeRouteFromDatabase(routeName: String) {
        FIRDatabase.database().reference().child("routes").child(routeName).removeValue()
    }
    
    /// Currently, updates whole structure. Subject to change after
    /// updating Route designer.
    func updateRouteInDatabase(route: Route) {
        FIRDatabase.database().reference().child("routes").child(route.name).setValue(route.toJSON())
    }
    
    func getUserProfile(uid: String, completion: @escaping (_ userProfile: UserProfile) -> ()) {
        FIRDatabase.database().reference().child("profiles").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any],
                  let profile = UserProfile(JSON: value) else {
                    return
            }
            completion(profile)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    /// Use in user profile.
    func getRoute(withName routeName: String, completion: @escaping (_ route: Route) -> ()) {
        FIRDatabase.database().reference().child("routes").child(routeName).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any],
                let route = Route(JSON: value) else {
                    return
            }
            completion(route)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func getRoutes(withName routeName: String, completion: @escaping (_ routes: [Route]) -> ()) {
        
    }
}
