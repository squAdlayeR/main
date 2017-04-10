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
    
    private(set) var isConnected: Bool = false //check connectivity
    static let instance = DatabaseManager()
    private(set) var currentUserProfile: UserProfile?
    
    func startObserveGPSTrack() {
        FIRDatabase.database().reference().child("gpstrack").observe(.childAdded, with: { snapshot in
            print("data received")
        })
    }
    
    func sendLocationInfoToDatabase(from: GeoPoint, to: GeoPoint) {
        DispatchQueue.global(qos: .background).async {
            // get the value
            self.formatter.maximumFractionDigits = 4
            self.formatter.minimumFractionDigits = 4
            let latEntry = String(format: "%.4f", from.latitude).replacingOccurrences(of: ".", with: "")//self.formatter.string(from: NSNumber(from.latitude))
            let lonEntry = String(format: "%.4f", to.latitude).replacingOccurrences(of: ".", with: "")
            //let lonEntry = self.formatter.string(from: NSNumber(from.longitude))
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
        var trackPoints: Set<TrackPoint> = []
        DispatchQueue.global(qos: .background).async {
            // data service here
            FIRDatabase.database().reference().child("gpstrack").queryOrdered(byChild: "latitude").queryStarting(atValue: fromLat).queryEnding(atValue: toLat).observeSingleEvent(of: .value, with: { snapshot in
                // snapshot value is [[String: Any]] parse
                guard let all = snapshot.value as? [[String: Any]] else {
                    //on same latitude, rare but can happen
                    guard let all = snapshot.value as? [String: Any] else {
                        return
                    }
                    guard let latdictcontent = all.values.first as? [String: Any] else {
                        return
                    }
                    print("1st ok")
                    var lat: Double?
                    var londicts: [[String: Any]] = []
                    for latdictvalue in latdictcontent.values {
                        if let latdictvalue = latdictvalue as? Double {
                            lat = latdictvalue
                            continue
                        } else if let latdictvalue = latdictvalue as? [String: Any] {
                            londicts.append(latdictvalue)
                            continue
                        }
                    }
                    guard let latv = lat else {
                        return
                    }
                    print("2nd ok")
                    for londict in londicts {
                        guard let lon = londict["longitude"] as? Double else {
                            return
                        }
                        print("3rd ok")
                        let trackPoint = TrackPoint(latv, lon)
                        if let _ = londict["up"] { trackPoint.up = true }
                        if let _ = londict["down"] { trackPoint.up = true }
                        if let _ = londict["left"] { trackPoint.up = true }
                        if let _ = londict["right"] { trackPoint.up = true }
                        if trackPoint.longitude < toLon && trackPoint.latitude > fromLon {
                            trackPoints.insert(trackPoint)
                        }
                    }
                    return
                }
                print("0th ok")
                for latdict in all {
                    guard let latdictcontent = latdict.values.first as? [String: Any] else {
                        continue
                    }
                    print("1st ok")
                    var lat: Double?
                    var londicts: [[String: Any]] = []
                    for latdictvalue in latdictcontent.values {
                        if let latdictvalue = latdictvalue as? Double {
                            lat = latdictvalue
                            continue
                        } else if let latdictvalue = latdictvalue as? [String: Any] {
                            londicts.append(latdictvalue)
                            continue
                        }
                    }
                    guard let latv = lat else {
                        return
                    }
                    print("2nd ok")
                    for londict in londicts {
                        guard let lon = londict["longitude"] as? Double else {
                            return
                        }
                        print("3rd ok")
                        let trackPoint = TrackPoint(latv, lon)
                        if let _ = londict["up"] { trackPoint.up = true }
                        if let _ = londict["down"] { trackPoint.up = true }
                        if let _ = londict["left"] { trackPoint.up = true }
                        if let _ = londict["right"] { trackPoint.up = true }
                        if trackPoint.longitude < toLon && trackPoint.latitude > fromLon {
                            trackPoints.insert(trackPoint)
                        }
                    }
                }
            })
            DispatchQueue.main.async {
                //completion block
                completion(trackPoints)
            }
        }
    }
    
    func addUserProfileToDatabase(uid: String, userProfile: UserProfile) {
        
        FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
    }
    
    func updateUserProfile(uid: String, userProfile: UserProfile) {
        currentUserProfile = userProfile
        FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
    }
    
    func addRouteToDatabase(route: Route) {
        
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(route.name) {
                print("route exists")
                return
            }
            FIRDatabase.database().reference().child("routes").child(route.name).setValue(route.toJSON())
            guard let uid = UserAuthenticator.instance.currentUser?.uid else { return }
            self.getUserProfile(uid: uid) { userProfile, success in
                guard success, let userProfile = userProfile else {
                    return
                }
                userProfile.designedRoutes.append(route.name)
                self.updateUserProfile(uid: uid, userProfile: userProfile)
            }
        })
        
    }
    
    func verifyUserProfile(uid: String, completion: @escaping () -> ()) {
        FIRDatabase.database().reference().child("profiles").observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.hasChild(uid) else {
                completion()
                return
            }
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
    
    func getUserProfile(uid: String, completion: @escaping (_ userProfile: UserProfile?, _ success: Bool) -> ()) {
        guard isConnected else {
            completion(nil, false)
            return
        }
        FIRDatabase.database().reference().child("profiles").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any],
                let profile = UserProfile(JSON: value) else {
                    completion(nil, false)
                    return
            }
            completion(profile, true)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    /// Use in user profile.
    func getRoute(withName routeName: String, completion: @escaping (_ route: Route) -> ()) {
        DispatchQueue.global(qos: .background).async {
            FIRDatabase.database().reference().child("routes").child(routeName).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any],
                    let points = value["checkPoints"] as? [[String: Any]],
                    let name = value["name"] as? String,
                    let checkPoints = points.map ({ CheckPoint(JSON: $0) }) as? [CheckPoint],
                    let image = value["imagePath"] as? String else { return }
                let route = Route(name, checkPoints)
                route.setImage(path: image)
                DispatchQueue.main.async {
                    completion(route)
                }
            }) { error in
                print(error.localizedDescription)
            }
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
                guard let points = result["checkPoints"] as? [[String: Any]],
                    let name = result["name"] as? String else {
                        continue
                }
                guard let checkPoints = points.map ({ CheckPoint(JSON: $0) }) as? [CheckPoint] else { return }
                let route = Route(name, checkPoints)
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
    
    func checkConnectivity() {
        DispatchQueue.global(qos: .background).async {
            let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
            connectedRef.observe(.value, with: { snapshot in
                print("called")
                guard let connected = snapshot.value as? Bool, connected else {
                    self.isConnected = false
                    UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.showAlertMessage(message: "Lost internet connection.")
                    return
                }
                self.isConnected = true
            })
        }
    }
    
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
