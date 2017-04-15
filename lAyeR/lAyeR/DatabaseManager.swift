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
    
    let formatter = NumberFormatter()
    
    private(set) var isConnected: Bool = false
    static let instance = DatabaseManager()
    private(set) var currentUserProfile: UserProfile?
    var connectivityCheckCount: Int = 0
    

    
    func sendLocationInfoToDatabase(from: GeoPoint, to: GeoPoint) {
        DispatchQueue.global(qos: .background).async {
            // get the value
            self.formatter.maximumFractionDigits = 4
            self.formatter.minimumFractionDigits = 4
            let latEntry = String(format: "%.4f", from.latitude).replacingOccurrences(of: ".", with: "")
            let lonEntry = String(format: "%.4f", from.longitude).replacingOccurrences(of: ".", with: "")
            // add value here
            var latdict: [String: Any] = [:]
            latdict["latitude"] = from.latitude
            var londict: [String: Any] = [:]
            londict["longitude"] = from.longitude
            if from.latitude < to.latitude { londict["up"] = true }
            if from.latitude > to.latitude { londict["down"] = true }
            if from.longitude > to.longitude { londict["left"] = true }
            if from.longitude < to.longitude { londict["right"] = true }
            latdict[lonEntry] = londict
            // get dirs
            FIRDatabase.database().reference().child("gpstrack").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.hasChild(latEntry) {
                    // update value here
                    let latRef = FIRDatabase.database().reference().child("gpstrack").child(latEntry)
                    let latSnapshot = snapshot.childSnapshot(forPath: latEntry)
                    if latSnapshot.hasChild(lonEntry) {
                        let lonRef = latRef.child(lonEntry)
                        if let _ = londict["up"] {
                            lonRef.child("up").setValue(true)
                        }
                        if let _ = londict["down"] {
                            lonRef.child("down").setValue(true)
                        }
                        if let _ = londict["left"] {
                            lonRef.child("left").setValue(true)
                        }
                        if let _ = londict["right"] {
                            lonRef.child("right").setValue(true)
                        }
                    } else {
                        latRef.child(lonEntry).setValue(londict)
                    }
                } else {
                    FIRDatabase.database().reference().child("gpstrack").child(latEntry).setValue(latdict)
                }
            })
            DispatchQueue.main.async {
                print("data sent")
            }
        }
    }
    
    func getRectFromDatabase(from: GeoPoint, to: GeoPoint, completion: @escaping (_ trackPoints: Set<TrackPoint>) -> ()) {
        let fromLat = min(from.latitude, to.latitude)
        let toLat = max(from.latitude, to.latitude)
        let fromLon = min(from.longitude, to.longitude)
        let toLon = max(from.longitude, to.longitude)
        print(fromLon, toLon)
        print("============")
        var trackPoints: Set<TrackPoint> = []
        DispatchQueue.global(qos: .background).async {
            // data service here
            FIRDatabase.database().reference().child("gpstrack").queryOrdered(byChild: "latitude").queryStarting(atValue: fromLat).queryEnding(atValue: toLat).observeSingleEvent(of: .value, with: { snapshot in
                if let all = snapshot.value as? [String: Any] {
                    for candidate in all.values {
                        guard let latdict = candidate as? [String: Any],
                            let lat = latdict["latitude"] as? Double else {
                                continue
                        }
                        var londicts: [[String: Any]] = []
                        for latdictvalue in latdict.values {
                            if let latdictvalue = latdictvalue as? [String: Any] {
                                londicts.append(latdictvalue)
                            }
                        }
                        for londict in londicts {
                            guard let lon = londict["longitude"] as? Double else {
                                continue
                            }
                            let trackPoint = TrackPoint(lat, lon)
                            if let _ = londict["up"] {
                                trackPoint.up = true }
                            if let _ = londict["down"] {
                                trackPoint.down = true }
                            if let _ = londict["left"] {
                                trackPoint.left = true }
                            if let _ = londict["right"] {
                                trackPoint.right = true }
                            if trackPoint.longitude <= toLon && trackPoint.longitude >= fromLon {
                                trackPoints.insert(trackPoint)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    //completion block
                    print(trackPoints.count)
                    completion(trackPoints)
                }
            })
        }
    }
    

    
    
    // ===================== USERPROFILE ==============================
    
    /// Creates a user profile in database.
    /// - Parameters:
    ///     - uid: String: user id
    ///     - userProfile: UserProfile: user profile to be added
    func addUserProfileToDatabase(uid: String, userProfile: UserProfile) {
        FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
    }
    
    /// Creates a user profile when user first sign in with facebook credential.
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
    
    /// Verifies if a user's profile exists and passes the result to completion handler.
    /// - Parameters:
    ///     - uid: String: user id
    ///     - completion: () -> ()
    private func verifyUserProfile(uid: String, completion: @escaping () -> ()) {
        FIRDatabase.database().reference().child("profiles").observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.hasChild(uid) else {
                completion()
                return
            }
        })
    }
    
    /// Gets user profile of user specified by user id, and passes result to completion handler.
    /// - Parameters:
    ///     - uid: String: user id of user
    ///     - completion: (UserProfile?) -> ()
    func getUserProfile(uid: String, completion: @escaping (_ userProfile: UserProfile?) -> ()) {
        FIRDatabase.database().reference().child("profiles").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as? [String: Any] ?? [:]
            let profile = UserProfile(JSON: value)
            completion(profile)
        }) 
    }
    
    /// Adds a user-designed route to the user's profile and updates the profile.
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
    
    /// Updates user profile.
    /// - Parameters:
    ///     - uid: String: user id
    ///     - userProfile: UserProfile: updated user profile
    func updateUserProfile(uid: String, userProfile: UserProfile) {
        DispatchQueue.global(qos: .background).async {
            self.currentUserProfile = userProfile
            FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
        }
    }
    
    // ===================== ROUTES ===================================
    
    /// Adds a route to database, and passes result to completion handler.
    /// - Parameters:
    ///     - uid: String: user id
    ///     - route: Route: route to be added in
    ///     - completion: (Bool?) -> ()
    func addRoute(uid: String, route: Route, completion: @escaping (_ success: Bool?) -> ()) {
        let combinedName = getRouteKey(uid, route.name)
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(combinedName) {
                completion(nil)
                return
            }
            FIRDatabase.database().reference().child("routes").child(combinedName).setValue(route.toJSON(), withCompletionBlock: { error, ref in
                completion(error == nil)
            })
        })
    }
    
    /// Returns the route with given name, and pass the result to completion handler.
    /// - Parameters:
    ///     - uid: String: user id of the user
    ///     - routeName: String: name of the route
    ///     - completion: (Route?) -> ()
    func getRoute(uid: String, named routeName: String, completion: @escaping (_ route: Route?) -> ()) {
        let combinedName = getRouteKey(uid, routeName)
        FIRDatabase.database().reference().child("routes").child(combinedName).observeSingleEvent(of: .value, with: { snapshot in
            let result = Parser.parseRoute(snapshot.value)
            completion(result)
        })
    }
    
    /// Returns the routes with given names in database and pass to completion handler.
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
    
    /// Queries routes in range specified by source and destination check point.
    /// Target routes should route segments whose source and destination is within
    /// the range which takes given source or destination as the search center.
    /// - Parameters:
    ///     - source: GeoPoint: source location
    ///     - destination: GeoPoint: destination location
    ///     - range: search radius in meters
    ///     - completion: ([Route]) -> ()
    func getRoutes(between source: GeoPoint, and destination: GeoPoint, inRange range: Double, completion: @escaping (_ routes: [Route]) -> ()) {
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { snapshot in
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
                if sourceIndex >= 0 && destIndex >= 0 {
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
            }
            completion(routes)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    /// Updates a route in database.
    /// - Parameters:
    ///     - uid: String: user id
    ///     - route: Route: route to be updated
    func updateRoute(uid: String, route: Route) {
        let combinedName = getRouteKey(uid, route.name)
        FIRDatabase.database().reference().child("routes").child(combinedName).setValue(route.toJSON())
    }
    
    /// Removes a route from database.
    /// - Parameter: 
    ///     - routeName: String: name of the route
    ///     - uid: user id
    func removeRoute(uid: String, routeName: String) {
        let combinedName = getRouteKey(uid, routeName)
        FIRDatabase.database().reference().child("routes").child(combinedName).removeValue()
    }
    
    // ===================== TRACKPOINTS ==============================
    
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
    
    /// Runs in background and observes the connection to the database.
    func startCheckConnectivity() {
        let connectedRef = FIRDatabase.database().reference(withPath: DatabaseConstants.connectKey)
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

