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
    
    func saveToDB(route: Route) {
        DataServiceManager.instance.addRouteToDatabase(route: route)
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
    
    private func getNextTrackPoint(from: TrackPoint, dir: Direction) -> TrackPoint {
        switch (dir) {
        case .up:    return TrackPoint(from.latitude + coordinateInterval, from.longitude)
        case .down:  return TrackPoint(from.latitude - coordinateInterval, from.longitude)
        case .left:  return TrackPoint(from.latitude, from.longitude - coordinateInterval)
        case .right: return TrackPoint(from.latitude, from.longitude + coordinateInterval)
        }
    }
    
    private func backtrack(from dest: TrackPointNode) -> [Route] {
        var currentTp = dest
        let ans = Route("GPS Route")
        while currentTp.parent != nil {
            ans.insert(currentTp.trackPoint, at: 0)
            currentTp = currentTp.parent!
        }
        ans.insert(currentTp.trackPoint, at: 0)
        var allRoutes = [Route]()
        allRoutes.append(ans)
        return allRoutes
        
    }
    
    private func aStarSearch(from source: TrackPoint, to dest: TrackPoint, using trackPoints: Set<TrackPoint>) -> [Route] {
        let startNode = TrackPointNode(trackPoint: source, parent: nil, g: 0, f: manhattanDistance(from: source, to: dest))
        var openSet = PriorityQueue(ascending: true, startingValues: [startNode])
        var closedSet = Dictionary<TrackPoint, Double>()
        closedSet[source] = 0.0
        
        for onePoint in trackPoints {
            print ("TWO POINT: \(onePoint.latitude) \(onePoint.longitude) \(onePoint.up) \(onePoint.down) \(onePoint.left) \(onePoint.right)")
        }
        
        while !openSet.isEmpty {
            let currentNode = openSet.pop()!
            let currentTrackPoint = currentNode.trackPoint
            if currentTrackPoint == dest {
                return backtrack(from: currentNode)
            }
            print ("Current Node: \(currentTrackPoint.latitude) \(currentTrackPoint.longitude)")
            let newcost = currentNode.g + coordinateInterval
            
            let useUp = getNextTrackPoint(from: currentTrackPoint, dir: .up)
            let upTrackPointIdx = trackPoints.index(of: useUp)
            if currentTrackPoint.up || (upTrackPointIdx != nil && trackPoints[upTrackPointIdx!].down) {
                print("CAN GO UP")
                print ("\(useUp.latitude) \(useUp.longitude) \(useUp.hashValue) \(trackPoints.contains(useUp))")
                print ("IDX: \(upTrackPointIdx)")
                if upTrackPointIdx != nil {
                    let nextTrackPoint = trackPoints[upTrackPointIdx!]
                    print ("Exist Node Up: \(nextTrackPoint.latitude) \(nextTrackPoint.longitude)")
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: nextTrackPoint, to: dest)))
                    }
                }
            }
            
            let useDown = getNextTrackPoint(from: currentTrackPoint, dir: .down)
            let downTrackPointIdx = trackPoints.index(of: useDown)
            if currentTrackPoint.down || (downTrackPointIdx != nil && trackPoints[downTrackPointIdx!].up) {
                print("CAN GO DOWN")
                print ("\(useDown.latitude) \(useDown.longitude) \(useDown.hashValue) \(trackPoints.contains(useDown))")
                print ("IDX: \(downTrackPointIdx)")
                if downTrackPointIdx != nil {
                    let nextTrackPoint = trackPoints[downTrackPointIdx!]
                    print ("Exist Node Up: \(nextTrackPoint.latitude) \(nextTrackPoint.longitude)")
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: nextTrackPoint, to: dest)))
                    }
                }
            }
            let useLeft = getNextTrackPoint(from: currentTrackPoint, dir: .left)
            let leftTrackPointIdx = trackPoints.index(of: useLeft)
            if currentTrackPoint.left || (leftTrackPointIdx != nil && trackPoints[leftTrackPointIdx!].right) {
                print("CAN GO LEFT")
                print ("\(useLeft.latitude) \(useLeft.longitude) \(useLeft.hashValue) \(trackPoints.contains(useLeft))")
                print ("IDX: \(leftTrackPointIdx)")
                if leftTrackPointIdx != nil {
                    let nextTrackPoint = trackPoints[leftTrackPointIdx!]
                    print ("Exist Node Up: \(nextTrackPoint.latitude) \(nextTrackPoint.longitude)")
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: nextTrackPoint, to: dest)))
                    }
                }
            }
            let useRight = getNextTrackPoint(from: currentTrackPoint, dir: .right)
            let rightTrackPointIdx = trackPoints.index(of: useRight)
            if currentTrackPoint.right || (rightTrackPointIdx != nil && trackPoints[rightTrackPointIdx!].left) {
                print("CAN GO RIGHT")
                print ("\(useRight.latitude) \(useRight.longitude) \(useRight.hashValue) \(trackPoints.contains(useRight))")
                print ("IDX: \(rightTrackPointIdx)")
                if rightTrackPointIdx != nil {
                    let nextTrackPoint = trackPoints[rightTrackPointIdx!]
                    print ("Exist Node Up: \(nextTrackPoint.latitude) \(nextTrackPoint.longitude)")
                    if closedSet[nextTrackPoint] == nil || closedSet[nextTrackPoint]! > newcost {
                        closedSet[nextTrackPoint] = newcost
                        openSet.push(TrackPointNode(trackPoint: nextTrackPoint, parent: currentNode, g: newcost, f: manhattanDistance(from: nextTrackPoint, to: dest)))
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
        // print("QUERY FROM: \(bottomLeft.latitude) \(bottomLeft.longitude)")
        // print("QUERY TO: \(topRight.latitude) \(topRight.longitude)")
        DatabaseManager.instance.getRectFromDatabase(from: bottomLeft, to: topRight) { (trackPoints) -> () in
            // DEBUG PURPOSES TO DRAW ENTIRE GRAPH
//            var routes = [Route]()
//            for onePoint in trackPoints {
//                if onePoint.up {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint, dir: .up)
//                    oneRoute.append(nextPoint)
//                    routes.append(oneRoute)
//                }
//                if onePoint.down {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint, dir: .down)
//                    oneRoute.append(nextPoint)
//                    routes.append(oneRoute)
//                }
//                if onePoint.left {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint, dir: .left)
//                    oneRoute.append(nextPoint)
//                    routes.append(oneRoute)
//                }
//                if onePoint.right {
//                    let oneRoute = Route("")
//                    oneRoute.append(onePoint)
//                    let nextPoint = self.getNextTrackPoint(from: onePoint, dir: .right)
//                    oneRoute.append(nextPoint)
//                    routes.append(oneRoute)
//                }
//                
//            }
//            print ("Routes Count \(routes.count)")
//            completion(routes)
            var sourceTp: TrackPoint?
            var destTp: TrackPoint?
            var smallestSourceDist = queryRadiusInCoordinates
            var smallestDestDist = queryRadiusInCoordinates
            // print ("Number of Points: \(trackPoints.count)")
            for onePoint in trackPoints {
                print ("ONE POINT: \(onePoint.latitude) \(onePoint.longitude) \(onePoint.up) \(onePoint.down) \(onePoint.left) \(onePoint.right) \(onePoint.hashValue)")
                let sourceDist = self.euclideanDistance(from: onePoint, to: source)
                if sourceDist < queryRadiusInCoordinates && sourceDist < smallestSourceDist {
                    smallestSourceDist = sourceDist
                    sourceTp = onePoint
                }
                let destDist = self.euclideanDistance(from: onePoint, to: dest)
                if destDist < queryRadiusInCoordinates && destDist < smallestDestDist {
                    smallestDestDist = destDist
                    destTp = onePoint
                }
            }
            if sourceTp == nil || destTp == nil || sourceTp == destTp {
                completion([Route]())
            } else {
                print ("SOURCE: \(sourceTp!.latitude) \(sourceTp!.longitude)")
                print ("DESTINATION: \(destTp!.latitude) \(destTp!.longitude)")
                completion(self.aStarSearch(from: sourceTp!, to: destTp!, using: trackPoints))
            }
        }
    }
}
