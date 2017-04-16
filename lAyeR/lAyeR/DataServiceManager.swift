//
//  DataServiceManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

/*
 * DataServiceManager handles database related activities with user authentication involved.
 */
class DataServiceManager {
    
    /// Returns the singleton instance of data service manager
    static let instance = DataServiceManager()
    
    /// Defines the user authenticator and database manager
    private(set) var userAuthenticator = UserAuthenticator.instance
    private(set) var databaseManager = DatabaseManager.instance
    
    /// Returns the current user id
    var currentUserID: String? {
        return userAuthenticator.currentUser?.uid
    }
    
    /// Returns true if user is authorized and database is connected
    var enabled: Bool {
        return currentUserID != nil && databaseManager.isConnected
    }
    
    // ===================== AUTHENTICATION =========================
    
    /// Creates a user with email and password authentication
    /// Adds the user profile to database and send verification email
    /// - Parameters:
    ///     - email: String: registration email
    ///     - password: String: registration password
    ///     - username: String: registration username
    ///     - registrationHandler: AuthenticationCallback
    ///     - verificationHandler: (Error?) -> ()
    func createUser(email: String, password: String, username: String, registrationHandler: @escaping AuthenticationCallback, verificationHandler: @escaping (Error?) -> ()) {
        userAuthenticator.createUser(email: email, password: password) {
            user, error in
            registrationHandler(user, error)
            guard let uid = user?.uid else {
                verificationHandler(error)
                return
            }
            DispatchQueue.global(qos: .background).async {
                let profile = UserProfile(email: email, username: username)
                self.databaseManager.addUserProfileToDatabase(uid: uid, userProfile: profile)
                self.userAuthenticator.sendEmailVerification(completion: { error in
                    DispatchQueue.main.async {
                        verificationHandler(error)
                    }
                })
            }
        }
    }
    
    /// Signs In a Facebook user and creates his profile
    /// - Parameters: 
    ///     - credential: AuthenticationCredential
    ///     - completion: AuthenticationCallback
    func signInUser(with credential: AuthenticationCredential, completion: @escaping AuthenticationCallback) {
        userAuthenticator.signInUser(with: credential) { (user, error) in
            completion(user, error)
            if let user = user {
                self.databaseManager.createFBUserProfile(user: user)
            }
        }
    }
    
    // ======================== DATABASE ============================
 
    // ------------------------- ROUTES -----------------------------
    
    /// Adds a route to database, updates user profile, passes result to completion handler
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
    
    /// Returns the route with given name, and pass the result to completion handler
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
    
    /// Returns the routes with given names in database and pass to completion handler
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
    
    /// Updates a route in database
    /// - Parameters:
    ///     - route: Route: route to be updated
    func updateRouteInDatabase(route: Route) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            return
        }
        databaseManager.updateRoute(uid: uid, route: route)
    }
    
    /// Removes a route from database
    /// - Parameter:
    ///     - routeName: String: name of the route
    func removeRouteFromDatabase(routeName: String) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            return
        }
        databaseManager.removeRoute(uid: uid, routeName: routeName)
    }
    
    // ----------------------- USERPROFILE ----------------------
    
    /// Retrieves current user profile
    /// - Parameters:
    ///     - completion: (UserProfile?) -> ()
    func retrieveUserProfile(completion: @escaping (_ userProfile: UserProfile?) -> ()) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            completion(nil)
            return
        }
        databaseManager.getUserProfile(uid: uid, completion: completion)
    }
    
    /// Updates user profile
    /// - Parameters:
    ///     - profile: UserProfile
    func updateUserProfile(_ profile: UserProfile) {
        guard let uid = currentUserID, databaseManager.isConnected else {
            return
        }
        databaseManager.updateUserProfile(uid: uid, userProfile: profile)
    }
    
}
