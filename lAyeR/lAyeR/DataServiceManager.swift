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
    
    func signInUser(email: String, password: String, completion: AuthenticationCallback?) {
        userAuthenticator.signInUser(email: email, password: password, completion: completion)
    }
    
    func signOut() {
        userAuthenticator.signOut()
    }
    
    func retrieveUserProfile(completion: @escaping (_ userProfile: UserProfile?) -> ()) {
        guard let user = userAuthenticator.currentUser else {
            completion(nil)
            return
        }
        databaseManager.getUserProfile(uid: user.uid, completion: completion)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // ======================= ROUTES ===========================
    
    /// Adds a route to database, updates user profile, passes result to completion handler.
    /// - Parameters:
    ///     - route: Route: route to be added in
    ///     - completion: (Bool?) -> ()
    func addRouteToDatabase(route: Route, completion: @escaping (_ success: Bool?) -> ()) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            completion(false)
            return
        }
        databaseManager.addRoute(uid: uid, route: route) { success in
            completion(success)
            if let success = success, success {
                DispatchQueue.global(qos: .background).async {
                    self.databaseManager.addRouteToUserProfile(uid: uid, routeName: route.name)
                }
            }
        }
    }
    
    /// Returns the route with given name, and pass the result to completion handler.
    /// - Parameters:
    ///     - routeName: String: name of the route
    ///     - completion: (Route?) -> ()
    func getRoute(named routeName: String, completion: @escaping (_ route: Route?) -> ()) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            completion(nil)
            return
        }
        databaseManager.getRoute(uid: uid, named: routeName, completion: completion)
    }
    
    /// Returns the routes with given names in database and pass to completion handler.
    /// - Parameters:
    ///     - names: Set<String>: names of routes
    ///     - completion: ([Route]) -> (): completion handler
    func getRoutes(with names: Set<String>, completion: @escaping (_ routes: [Route]?) -> ()) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            completion(nil)
            return
        }
        databaseManager.getRoutes(uid: uid, with: names, completion: completion)
    }
    
    /// Updates a route in database.
    /// - Parameters:
    ///     - route: Route: route to be updated
    func updateRouteInDatabase(route: Route) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            return
        }
        databaseManager.updateRoute(uid: uid, route: route)
    }
    
    /// Removes a route from database.
    /// - Parameter:
    ///     - routeName: String: name of the route
    func removeRouteFromDatabase(routeName: String) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            return
        }
        databaseManager.removeRoute(uid: uid, routeName: routeName)
    }
    
    
    // ===================== USERPROFILE ========================
    
    /// Creates a user profile when user first sign in with facebook credential.
    /// - Parameters:
    ///     - user: User: user whose profile is to be stored
    func createFBUserProfile(user: User) {
        databaseManager.createFBUserProfile(user: user)
    }
    
    
    

    
    
    
    
    
    
    
    
    
    

}
