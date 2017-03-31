//
//  DatabaseManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseDatabase

class DatabaseManager {
    
    static let instance = DatabaseManager()
    
    func addUserToDatabase(user: User) {
        FIRDatabase.database().reference().child("users").child(user.uid).setValue(user.toJSON())
    }
    
    func addRouteToDatabase(route: Route) {
        FIRDatabase.database().reference().child("routes").child(route.name).setValue(route.toJSON())
    }
    
    func removeRouteFromDatabase(routeName: String) {
        FIRDatabase.database().reference().child("routes").child(routeName).removeValue()
    }
    
    // how?
    func updateRouteInDatabase(){
    }
    
}
