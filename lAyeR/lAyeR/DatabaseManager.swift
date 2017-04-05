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
        
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(route.name) {
                print("route exists")
                return
            }
            FIRDatabase.database().reference().child("routes").child(route.name).setValue(route.toJSON())
        })
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
    
    /// Queries routes with name
    func getRoutes(withName name: String, completion: @escaping (_ routes: [Route]) -> ()) {
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                    return
            }
            var routes: [Route] = []
            for result in value.values {
                guard let route = Route(JSON: result) else { continue }
                if route.name.contains(name) {
                    routes.append(route)
                }
            }
            completion(routes)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    /// Queries routes in range
    func getRoutes(between source: GeoPoint, and destination: GeoPoint, inRange range: Double, completion: @escaping (_ routes: [Route]) -> ()) {
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                return
            }
            var routes: [Route] = []
            for result in value.values {
                guard let route = Route(JSON: result) else { continue }
                var sourceIndex = -1
                var destIndex = -1
                for i in 0 ..< route.size {
                    if GeoUtil.getCoordinateDistance(route.checkPoints[i], source) < range {
                        sourceIndex = i
                    } else if GeoUtil.getCoordinateDistance(route.checkPoints[i], destination) < range {
                        destIndex = i
                    }
                }
                if sourceIndex >= 0 && destIndex >= 0 {
                    let section = destIndex >= sourceIndex ? route.checkPoints[sourceIndex ... destIndex] : route.checkPoints[destIndex ... sourceIndex]
                    let returnRoute = Route(route.name)
                    for checkpoint in section {
                        returnRoute.append(checkpoint)
                    }
                    routes.append(returnRoute)
                }
            }
            completion(routes)
        }) { error in
            print(error.localizedDescription)
        }
    }
}
