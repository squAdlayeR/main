//
//  RouteDesignerModel.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/7/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

class RouteDesignerModel {

    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    let coordinateInterval = 0.0001
    
    // ---------------- Save Routes --------------------//
    
    func saveToLocal(route: Route) {
        RealmLocalStorageManager.getInstance().saveRoute(route)
    }
    
    func saveToDB(route: Route,  completion: @escaping (Bool)->()) {
        DataServiceManager.instance.addRouteToDatabase(route: route, completion: completion)
    }

    // ---------------- Get Google Routes --------------------//
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>?, at markersIdx: Int, completion: @escaping (_ result: Bool, _ path: GMSPath?)->()) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&mode=walking"
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                let directionsURL = NSURL(string: directionsURLString)
                DispatchQueue.main.async( execute: { () -> Void in
                    let directionsData = NSData(contentsOf: directionsURL! as URL)
                    if directionsData == nil {
                        completion(false, nil)
                        return
                    }
                    do{
                        let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            
                            let selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            let overviewPolyline = selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                            
                            let route = overviewPolyline["points"] as! String
                            let path: GMSPath = GMSPath(fromEncodedPath: route)!
                            
                            if path.count() > 1 {
                                completion(true, path)
                            } else {
                                completion(false, path)
                            }
                        }
                        else {
                            completion(false, nil)
                        }
                    }
                    catch {
                        completion(false, nil)
                    }
                })
            }
            else {
                completion(false, nil)
            }
        }
        else {
            completion(false, nil)
        }
    }
    
    // ---------------- Get Layer Routes --------------------//
    
    func getLayerRoutes(source: GeoPoint, dest: GeoPoint, completion: @escaping (_ routes: [Route]) -> ()) {
        
        var routes = RealmLocalStorageManager.getInstance().getRoutes(between: source, and: dest, inRange: UserConfig.queryRadius)
        DatabaseManager.instance.getRoutes(between: source, and: dest, inRange: UserConfig.queryRadius) { (dbRoutes) -> () in
            routes.append(contentsOf: dbRoutes)
            completion(routes)
        }
    }
    
    // ---------------- Distance Functions --------------------//
    
    private func euclideanDistance(from source: GeoPoint, to dest: GeoPoint) -> Double {
        let dist = sqrt((source.latitude - dest.latitude) * (source.latitude - dest.latitude) + (source.longitude - dest.longitude) * (source.longitude - dest.longitude))
        return dist
    }
    
    private func manhattanDistance(from source: GeoPoint, to dest: GeoPoint) -> Double {
        let dist = abs(source.latitude - dest.latitude) + abs(source.longitude - dest.longitude)
        return dist
    }
    
    // ---------------- A* Search Algorithm --------------------//
    
    private enum Direction {
        case up
        case down
        case left
        case right
    }
    
    private func getNextTrackPoint(from: TrackPointStruct, dir: Direction) -> TrackPointStruct {
        switch (dir) {
        case .up:    return TrackPointStruct(from.latitude + coordinateInterval, from.longitude)
        case .down:  return TrackPointStruct(from.latitude - coordinateInterval, from.longitude)
        case .left:  return TrackPointStruct(from.latitude, from.longitude - coordinateInterval)
        case .right: return TrackPointStruct(from.latitude, from.longitude + coordinateInterval)
        }
    }
    
    private func backtrack(from dest: TrackPointNode) -> [Route] {
        var currentTp = dest
        let ans = Route("GPS Route")
        var allRoutes = [Route]()
        
        if currentTp.parent != nil {
            ans.insert(CheckPoint(currentTp.trackPoint.latitude, currentTp.trackPoint.longitude, "", "", true), at: 0)
            currentTp = currentTp.parent!
        }
        
        while currentTp.parent != nil {
            ans.insert(CheckPoint(currentTp.trackPoint.latitude, currentTp.trackPoint.longitude, "", "", false), at: 0)
            currentTp = currentTp.parent!
        }
        
        ans.insert(CheckPoint(currentTp.trackPoint.latitude, currentTp.trackPoint.longitude, "", "", false), at: 0)
        
        allRoutes.append(ans)
        return allRoutes
        
    }
    
    private func aStarSearch(from source: TrackPointStruct, to dest: TrackPointStruct, using trackPointStructs: Set<TrackPointStruct>) -> [Route] {
        let startNode = TrackPointNode(trackPoint: source, parent: nil, g: 0, f: manhattanDistance(from: GeoPoint(source.latitude, source.longitude), to: GeoPoint(dest.latitude, dest.longitude)))
        var openSet = PriorityQueue(ascending: true, startingValues: [startNode])
        var closedSet = Dictionary<TrackPointStruct, Double>()
        closedSet[source] = 0.0
        
        
        while !openSet.isEmpty {
            let currentNode = openSet.pop()!
            let currentTrackPoint = currentNode.trackPoint
            if currentTrackPoint == dest {
                return backtrack(from: currentNode)
            }
            let newcost = currentNode.g + coordinateInterval
            
            let useUp = getNextTrackPoint(from: currentTrackPoint, dir: .up)
            let upTrackPointIdx = trackPointStructs.index(of: useUp)
            if currentTrackPoint.up {
                if upTrackPointIdx != nil {
                    let nextTrackPoint = trackPointStructs[upTrackPointIdx!]
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: GeoPoint(nextTrackPoint.latitude, nextTrackPoint.longitude), to: GeoPoint(dest.latitude, dest.longitude))))
                    }
                }
            }
            
            let useDown = getNextTrackPoint(from: currentTrackPoint, dir: .down)
            let downTrackPointIdx = trackPointStructs.index(of: useDown)
            if currentTrackPoint.down {
                if downTrackPointIdx != nil {
                    let nextTrackPoint = trackPointStructs[downTrackPointIdx!]
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: GeoPoint(nextTrackPoint.latitude, nextTrackPoint.longitude), to: GeoPoint(dest.latitude, dest.longitude))))
                    }
                }
            }
            let useLeft = getNextTrackPoint(from: currentTrackPoint, dir: .left)
            let leftTrackPointIdx = trackPointStructs.index(of: useLeft)
            if currentTrackPoint.left {
                if leftTrackPointIdx != nil {
                    let nextTrackPoint = trackPointStructs[leftTrackPointIdx!]
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: GeoPoint(nextTrackPoint.latitude, nextTrackPoint.longitude), to: GeoPoint(dest.latitude, dest.longitude))))
                    }
                }
            }
            let useRight = getNextTrackPoint(from: currentTrackPoint, dir: .right)
            let rightTrackPointIdx = trackPointStructs.index(of: useRight)
            if currentTrackPoint.right {
                if rightTrackPointIdx != nil {
                    let nextTrackPoint = trackPointStructs[rightTrackPointIdx!]
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: GeoPoint(nextTrackPoint.latitude, nextTrackPoint.longitude), to: GeoPoint(dest.latitude, dest.longitude))))
                    }
                }
            }
        }
        return [Route]()
    }
    
    // ---------------- Get GPS Routes --------------------//
    
    func getGpsRoutes(source: GeoPoint, dest: GeoPoint, completion: @escaping (_ routes: [Route]) -> ()) {
        let queryRadiusInCoordinates = 0.00001 * UserConfig.queryRadius
        let minLat = min(source.latitude, dest.latitude)
        let maxLat = max(source.latitude, dest.latitude)
        let minLon = min(source.longitude, dest.longitude)
        let maxLon = max(source.longitude, dest.longitude)
        let bottomLeft = GeoPoint(minLat - queryRadiusInCoordinates, minLon - queryRadiusInCoordinates)
        let topRight = GeoPoint(maxLat + queryRadiusInCoordinates, maxLon + queryRadiusInCoordinates)
        
        DatabaseManager.instance.getRectFromDatabase(from: bottomLeft, to: topRight) { (trackPoints) -> () in
            
//            For Debugging Purposes. Draws the entire grid graph
//            var routes = [Route]()
//            for onePoint in trackPoints {
//                if onePoint.up {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint.convertToStruct(), dir: .up)
//                    oneRoute.append(CheckPoint(nextPoint.latitude, nextPoint.longitude, "\(nextPoint.latitude), \(nextPoint.longitude)", "", false))
//                    routes.append(oneRoute)
//                }
//                if onePoint.down {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint.convertToStruct(), dir: .down)
//                    oneRoute.append(CheckPoint(nextPoint.latitude, nextPoint.longitude, "\(nextPoint.latitude), \(nextPoint.longitude)", "", false))
//                    routes.append(oneRoute)
//                }
//                if onePoint.left {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint.convertToStruct(), dir: .left)
//                    oneRoute.append(CheckPoint(nextPoint.latitude, nextPoint.longitude, "\(nextPoint.latitude), \(nextPoint.longitude)", "", false))
//                    routes.append(oneRoute)
//                }
//                if onePoint.right {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint.convertToStruct(), dir: .right)
//                    oneRoute.append(CheckPoint(nextPoint.latitude, nextPoint.longitude, "\(nextPoint.latitude), \(nextPoint.longitude)", "", false))
//                    routes.append(oneRoute)
//                }
//                
//            }
//            completion(routes)
            
            
            // Convert into TrackPointStruct for Set.contains
            var trackPointStructs = Set<TrackPointStruct>()
            for onePoint in trackPoints {
                trackPointStructs.insert(onePoint.convertToStruct())
            }
            let tempTrackPointStructs = trackPointStructs
            
            // Ensure that required graph properties are upheld
            // 1. Bidirectional
            // 2. Edge goes from one existing vertex to another existing vertex
            for onePoint in tempTrackPointStructs {
                if onePoint.up {
                    let useUp = self.getNextTrackPoint(from: onePoint, dir: .up)
                    if trackPointStructs.contains(useUp) {
                        var oldPoint = trackPointStructs[trackPointStructs.index(of: useUp)!]
                        oldPoint.down = true
                        trackPointStructs.update(with: oldPoint)
                    } else {
                        var newPoint = TrackPointStruct(useUp.latitude, useUp.longitude)
                        newPoint.down = true
                        trackPointStructs.insert(newPoint)
                    }
                }
                if onePoint.down {
                    let useDown = self.getNextTrackPoint(from: onePoint, dir: .down)
                    if trackPointStructs.contains(useDown) {
                        var oldPoint = trackPointStructs[trackPointStructs.index(of: useDown)!]
                        oldPoint.up = true
                        trackPointStructs.update(with: oldPoint)
                    } else {
                        var newPoint = TrackPointStruct(useDown.latitude, useDown.longitude)
                        newPoint.up = true
                        trackPointStructs.insert(newPoint)
                    }
                }
                if onePoint.left {
                    let useLeft = self.getNextTrackPoint(from: onePoint, dir: .left)
                    if trackPointStructs.contains(useLeft) {
                        var oldPoint = trackPointStructs[trackPointStructs.index(of: useLeft)!]
                        oldPoint.right = true
                        trackPointStructs.update(with: oldPoint)
                    } else {
                        var newPoint = TrackPointStruct(useLeft.latitude, useLeft.longitude)
                        newPoint.right = true
                        trackPointStructs.insert(newPoint)
                    }
                }
                if onePoint.right {
                    let useRight = self.getNextTrackPoint(from: onePoint, dir: .right)
                    if trackPointStructs.contains(useRight) {
                        var oldPoint = trackPointStructs[trackPointStructs.index(of: useRight)!]
                        oldPoint.left = true
                        trackPointStructs.update(with: oldPoint)
                    } else {
                        var newPoint = TrackPointStruct(useRight.latitude, useRight.longitude)
                        newPoint.left = true
                        trackPointStructs.insert(newPoint)
                    }
                }
            }
            
            var sourceTp: TrackPointStruct?
            var destTp: TrackPointStruct?
            var smallestSourceDist = queryRadiusInCoordinates
            var smallestDestDist = queryRadiusInCoordinates
            // print ("Number of Points: \(trackPoints.count)")
            for onePoint in trackPointStructs {
                let sourceDist = self.euclideanDistance(from: GeoPoint(onePoint.latitude, onePoint.longitude), to: source)
                if sourceDist < queryRadiusInCoordinates && sourceDist < smallestSourceDist {
                    smallestSourceDist = sourceDist
                    sourceTp = onePoint
                }
                let destDist = self.euclideanDistance(from: GeoPoint(onePoint.latitude, onePoint.longitude), to: dest)
                if destDist < queryRadiusInCoordinates && destDist < smallestDestDist {
                    smallestDestDist = destDist
                    destTp = onePoint
                }
            }
            if sourceTp == nil || destTp == nil || sourceTp == destTp {
                completion([Route]())
            } else {
                completion(self.aStarSearch(from: sourceTp!, to: destTp!, using: trackPointStructs))
            }
        }
    }
}
