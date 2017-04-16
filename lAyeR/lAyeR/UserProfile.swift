//
//  UserProfile.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/1.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper
/*
 * This class is used represent user profile data structure.
 * A user profile should contain:
 * - username: String
 * - email: String
 * - avatarRef: String, the string path of the user icon image
 * - designedRoutes: [String], the names of user designed routes
 */
class UserProfile: Mappable {
    
    /// Defines the attributes of user profile
    private(set) var avatarRef: String = ModelConstants.defaultUserIcon
    private(set) var username: String = ModelConstants.defaultUserName
    private(set) var email: String
    private(set) var designedRoutes: [String] = []
    
    /// Initializes UserProfile
    /// - Parameters:
    ///     - email: String: user email
    ///     - username: String: user name
    init(email: String, username: String) {
        self.email = email
        self.username = username
    }
    
    /// Initializes UserProfile from serializable map
    /// - Parameters:
    ///     - map: Map: mapping of the fields
    /// MARK: This initializer utilizes ObjectMapper framework
    required init?(map: Map) {
        guard let username = map.JSON[ModelConstants.usernameKey] as? String,
            let email = map.JSON[ModelConstants.emailKey] as? String,
            let avatarRef = map.JSON[ModelConstants.avatarRefKey] as? String else {
                return nil
        }
        self.username = username
        self.email = email
        self.avatarRef = avatarRef
        self.designedRoutes = map.JSON[ModelConstants.designedRouteKey] as? [String] ?? []
    }
    
    /// Maps fields with map
    func mapping(map: Map) {
        username <- map[ModelConstants.usernameKey]
        email <- map[ModelConstants.emailKey]
        avatarRef <- map[ModelConstants.avatarRefKey]
        designedRoutes <- map[ModelConstants.designedRouteKey]
    }
    
    /// Sets user avatar
    /// - Parameter avaRef: String: filepath of new image
    func setAvatar(_ avatarRef: String) {
        self.avatarRef = avatarRef
    }
    
    /// Removes the route specified by index
    /// - Parameter index: Int: the index of the route to remove
    func removeDesignedRoute(_ index: Int) {
        designedRoutes.remove(at: index)
    }
    
    /// Adds a designed route to user profile
    /// - Parameter routeName: String: the name of the newly added route
    func addDesignedRoute(_ routeName: String) {
        designedRoutes.append(routeName)
    }
}
