//
//  DatabaseManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper
import FirebaseDatabase
import FirebaseAuth

class DatabaseManager {
    
    let formatter = NumberFormatter()
    
    static let instance = DatabaseManager()
    private(set) var isConnected: Bool = false
    private(set) var currentUserProfile: UserProfile?
    
    // ===================== USERPROFILE ==============================
    
    /// Creates a user profile in database.
    /// - Parameters:
    ///     - uid: String: user id
    ///     - userProfile: UserProfile: user profile to be added
    func addUserProfileToDatabase(uid: String, userProfile: UserProfile) {
        Database.database().reference().child(DatabaseConstants.profilesKey).child(uid).setValue(userProfile.toJSON())
    }
    
    /// Creates a user profile when user first sign in with facebook credential
    /// - Parameters:
    ///     - user: User: user whose profile is to be stored
    func createFBUserProfile(user: User) {
        DispatchQueue.global(qos: .background).async {
            self.verifyUserProfile(uid: user.uid) {
                guard let email = user.email,
                    let avartarRef = user.photoURL?.absoluteString,
                    let userName = user.displayName else {
                        return
                }
                let profile = UserProfile(email: email, username: userName)
                profile.setAvatar(avartarRef)
                self.addUserProfileToDatabase(uid: user.uid, userProfile: profile)
            }
        }
    }
    
    /// Verifies if a user's profile exists and passes the result to completion handler
    /// - Parameters:
    ///     - uid: String: user id
    ///     - completion: () -> ()
    private func verifyUserProfile(uid: String, completion: @escaping () -> ()) {
        Database.database().reference().child(DatabaseConstants.profilesKey).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.hasChild(uid) else {
                completion()
                return
            }
        })
    }
    
    /// Gets user profile of user specified by user id, and passes result to completion handler
    /// - Parameters:
    ///     - uid: String: user id of user
    ///     - completion: (UserProfile?) -> ()
    func getUserProfile(uid: String, completion: @escaping (_ userProfile: UserProfile?) -> ()) {
        Database.database().reference().child(DatabaseConstants.profilesKey).child(uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? [String: Any] ?? [:]
            let profile = UserProfile(JSON: value)
            completion(profile)
        }) 
    }
    
    /// Adds a user-designed route to the user's profile and updates the profile
    /// - Parameters:
    ///     - uid: String: user id
    ///     - routeName: String: name of the route
    func addRouteToUserProfile(uid: String, routeName: String) {
        getUserProfile(uid: uid) { userProfile in
            guard let userProfile = userProfile else {
                return
            }
            userProfile.addDesignedRoute(routeName)
            self.updateUserProfile(uid: uid, userProfile: userProfile)
        }
    }
    
    /// Updates user profile
    /// - Parameters:
    ///     - uid: String: user id
    ///     - userProfile: UserProfile: updated user profile
    func updateUserProfile(uid: String, userProfile: UserProfile) {
        DispatchQueue.global(qos: .background).async {
            self.currentUserProfile = userProfile
            Database.database().reference().child(DatabaseConstants.profilesKey).child(uid).setValue(userProfile.toJSON())
        }
    }
    
    // ===================== ROUTES ===================================
    
    /// Adds a route to database, and passes result to completion handler
    /// - Parameters:
    ///     - uid: String: user id
    ///     - route: Route: route to be added in
    ///     - completion: (Bool?) -> ()
    func addRoute(uid: String, route: Route, completion: @escaping (_ success: Bool?) -> ()) {
        let combinedName = getRouteKey(uid, route.name)
        Database.database().reference().child(DatabaseConstants.routesKey).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(combinedName) {
                completion(nil)
                return
            }
            Database.database().reference().child(DatabaseConstants.routesKey).child(combinedName).setValue(route.toJSON(), withCompletionBlock: { error, ref in
                completion(error == nil)
            })
        })
    }
    
    /// Returns the route with given name, and pass the result to completion handler
    /// - Parameters:
    ///     - uid: String: user id of the user
    ///     - routeName: String: name of the route
    ///     - completion: (Route?) -> ()
    func getRoute(uid: String, named routeName: String, completion: @escaping (_ route: Route?) -> ()) {
        let combinedName = getRouteKey(uid, routeName)
        Database.database().reference().child(DatabaseConstants.routesKey).child(combinedName).observeSingleEvent(of: .value, with: { snapshot in
            let result = Parser.parseRoute(snapshot.value)
            completion(result)
        })
    }
    
    /// Returns the routes with given names in database and pass to completion handler
    /// - Parameters:
    ///     - uid: String: user id of the user
    ///     - names: Set<String>: names of routes
    ///     - completion: ([Route]) -> (): completion handler
    func getRoutes(uid: String, with names: Set<String>, completion: @escaping (_ routes: [Route]) -> ()) {
        let group = DispatchGroup()
        var routes: [Route] = []
        for name in names {
            group.enter()
            getRoute(uid: uid, named: name) { route in
                if let route = route {
                    routes.append(route)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(routes)
        }
    }
    
    /// Queries routes in range specified by source and destination check point
    /// Target routes should route segments whose source and destination is within
    /// the range which takes given source or destination as the search center
    /// - Parameters:
    ///     - source: GeoPoint: source location
    ///     - destination: GeoPoint: destination location
    ///     - range: search radius in meters
    ///     - completion: ([Route]) -> ()
    func getRoutes(between source: GeoPoint, and destination: GeoPoint, inRange range: Double, completion: @escaping (_ routes: [Route]) -> ()) {
        Database.database().reference().child(DatabaseConstants.routesKey).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            var routes: [Route] = []
            for result in value.values {
                guard let route = Parser.parseRoute(result) else {
                    continue
                }
                var sourceIndex = -1
                var destIndex = -1
                var sourceDist = range
                var destDist = range
                for i in 0 ..< route.size {
                    let newSourceDist = GeoUtil.getCoordinateDistance(route.checkPoints[i], source)
                    if newSourceDist < sourceDist {
                        sourceIndex = i
                        sourceDist = newSourceDist
                    }
                    let newDestDist = GeoUtil.getCoordinateDistance(route.checkPoints[i], destination)
                    if  newDestDist < destDist {
                        destIndex = i
                        destDist = newDestDist
                    }
                }
                if sourceIndex == destIndex {
                    continue
                }
                guard sourceIndex >= 0 && destIndex >= 0 else {
                    continue
                }
                let section = destIndex > sourceIndex ? route.checkPoints[sourceIndex ... destIndex] : route.checkPoints[destIndex ... sourceIndex]
                let returnRoute = Route(route.name)
                for checkpoint in section {
                    if destIndex > sourceIndex {
                        returnRoute.append(checkpoint)
                    } else {
                        returnRoute.insert(checkpoint, at: 0)
                    }
                }
                routes.append(returnRoute)
            }
            completion(routes)
        })
    }
    
    /// Updates a route in database
    /// - Parameters:
    ///     - uid: String: user id
    ///     - route: Route: route to be updated
    func updateRoute(uid: String, route: Route) {
        let combinedName = getRouteKey(uid, route.name)
        Database.database().reference().child(DatabaseConstants.routesKey).child(combinedName).setValue(route.toJSON())
    }
    
    /// Removes a route from database
    /// - Parameter: 
    ///     - routeName: String: name of the route
    ///     - uid: user id
    func removeRoute(uid: String, routeName: String) {
        let combinedName = getRouteKey(uid, routeName)
        Database.database().reference().child(DatabaseConstants.routesKey).child(combinedName).removeValue()
    }
    
    // ===================== TRACKPOINTS ==============================
    
    /// Sends track point location information to database
    /// - Parameters:
    ///     - from: GeoPoint: start point of the edge
    ///     - to: GeoPoint: end point of the edge
    /// MARK: This process is run in background
    func sendLocationInfoToDatabase(from: GeoPoint, to: GeoPoint) {
        DispatchQueue.global(qos: .background).async {
            let latEntry = self.getCoordKey(from.latitude)
            let lonEntry = self.getCoordKey(from.longitude)
            var latdict: [String: Any] = [:]
            latdict[ModelConstants.latitudeKey] = from.latitude
            var londict: [String: Any] = [:]
            londict[ModelConstants.longitudeKey] = from.longitude
            if from.latitude < to.latitude { londict[ModelConstants.upKey] = true }
            if from.latitude > to.latitude { londict[ModelConstants.downKey] = true }
            if from.longitude > to.longitude { londict[ModelConstants.leftKey] = true }
            if from.longitude < to.longitude { londict[ModelConstants.rightKey] = true }
            latdict[lonEntry] = londict
            // get dirs
            Database.database().reference().child(DatabaseConstants.gpstrackKey).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.hasChild(latEntry) {
                    // update value here
                    let latRef = Database.database().reference().child(DatabaseConstants.gpstrackKey).child(latEntry)
                    let latSnapshot = snapshot.childSnapshot(forPath: latEntry)
                    if latSnapshot.hasChild(lonEntry) {
                        let lonRef = latRef.child(lonEntry)
                        if let _ = londict[ModelConstants.upKey] {
                            lonRef.child(ModelConstants.upKey).setValue(true)
                        }
                        if let _ = londict[ModelConstants.downKey] {
                            lonRef.child(ModelConstants.downKey).setValue(true)
                        }
                        if let _ = londict[ModelConstants.leftKey] {
                            lonRef.child(ModelConstants.leftKey).setValue(true)
                        }
                        if let _ = londict[ModelConstants.rightKey] {
                            lonRef.child(ModelConstants.rightKey).setValue(true)
                        }
                    } else {
                        latRef.child(lonEntry).setValue(londict)
                    }
                } else {
                    Database.database().reference().child(DatabaseConstants.gpstrackKey).child(latEntry).setValue(latdict)
                }
            })
        }
    }
    
    /// Gets the trackpoints in the rectangle grid specified by a from point and a to point
    /// as diagnol, passes the result to completion handler
    /// - Parameters:
    ///     - from: GeoPoint: the source
    ///     - to: GeoPoint: the destination
    ///     - completion: (Set<TrackPoint>) -> ()
    func getRectFromDatabase(from: GeoPoint, to: GeoPoint, completion: @escaping (_ trackPoints: Set<TrackPoint>) -> ()) {
        let fromLat = min(from.latitude, to.latitude)
        let toLat = max(from.latitude, to.latitude)
        let fromLon = min(from.longitude, to.longitude)
        let toLon = max(from.longitude, to.longitude)
        var trackPoints: Set<TrackPoint> = []
        DispatchQueue.global(qos: .background).async {
            // data service here
            Database.database().reference().child(DatabaseConstants.gpstrackKey).queryOrdered(byChild: ModelConstants.latitudeKey).queryStarting(atValue: fromLat).queryEnding(atValue: toLat).observeSingleEvent(of: .value, with: { snapshot in
                if let all = snapshot.value as? [String: Any] {
                    for candidate in all.values {
                        let points = Parser.parseTrackPoints(candidate)
                        points.forEach({ point in
                            if point.longitude <= toLon && point.longitude >= fromLon {
                                trackPoints.insert(point)
                            }
                        })
                    }
                }
                DispatchQueue.main.async {
                    completion(trackPoints)
                }
            })
        }
    }
    
    // ===================== UTILITIES ================================
    
    /// Returns the route key of the route. Route name is combined with user id to create a
    /// inidivual-unique route entry in database.
    /// - Parameters:
    ///     - uid: String: user id
    ///     - routeName: String: name of the route
    /// - Returns:
    ///     - String: combined name as route entry
    private func getRouteKey(_ uid: String, _ routeName: String) -> String {
        return "\(routeName)\(DatabaseConstants.separator)\(uid)"
    }
    
    /// Returns the formatted coordinate degree value as the entry in the JSON
    /// - Parameters:
    ///     - coord: Double: value of the coordinate in degrees
    /// - Returns:
    ///     - String: formatted string
    private func getCoordKey(_ coord: Double) -> String {
        formatter.maximumFractionDigits = GPSGPXConstants.precision
        formatter.minimumFractionDigits = GPSGPXConstants.precision
        return String(format: DatabaseConstants.format, coord).replacingOccurrences(of: ".", with: "")
    }
    
    /// Runs in background and observes the connection to the database
    func startCheckConnectivity() {
        let connectedRef = Database.database().reference(withPath: DatabaseConstants.connectKey)
        DispatchQueue.global(qos: .background).async {
            connectedRef.observe(.value, with: { snapshot in
                guard let connected = snapshot.value as? Bool else {
                    return
                }
                guard connected else {
                    self.isConnected = false
                    DispatchQueue.main.async {
                        // feedback to main queue
                    }
                    return
                }
                self.isConnected = true
            })
        }
    }
    
}

