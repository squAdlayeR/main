//
//  GPXParser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/6.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

class GPSTrackerParser {
    
    static let instace = GPSTrackerParser()
    
    private let creator = "lAyeR"
    
    func parseRouteToGPX(route: Route) throws -> String {
        guard let root = GPXRoot(creator: creator) else {
            throw GPXError.createFailure
        }
        let gpxRoute = GPXRoute()
        gpxRoute.name = route.name
        for point in route.checkPoints {
            let gpxPoint = GPXRoutePoint()
            gpxPoint.name = point.name
            gpxPoint.desc = point.description
            gpxPoint.latitude = CGFloat(point.latitude)
            gpxPoint.longitude = CGFloat(point.longitude)
            gpxPoint.comment = point.isControlPoint.description
            gpxRoute.addRoutepoint(gpxPoint)
        }
        root.addRoute(gpxRoute)
        return root.gpx()
    }
    
    func parseGPXToRoute(url: URL) throws -> [Route] {
        guard let root = GPXParser.parseGPX(at: url) else {
            throw GPXError.readFailure
        }
        guard let gpxRoutes = root.routes as? [GPXRoute] else {
            throw GPXError.noGPXRouteFound
        }
        var routes: [Route] = []
        for gpxRoute in gpxRoutes {
            let route = Route(gpxRoute.name)
            let points = gpxRoute.routepoints as? [GPXRoutePoint] ?? []
            for point in points {
                let lat = point.latitude
                let lng = point.longitude
                let name = point.name ?? "CheckPoint"
                let desc = point.desc ?? ""
                let isControlPoint = point.comment == "true" ? true: false
                let checkPoint = CheckPoint(Double(lat), Double(lng), name, desc, isControlPoint)
                route.append(checkPoint)
            }
            routes.append(route)
        }
        return routes
    }
    
    func parseKMLToRoute(url: URL) -> [Route] {
        guard let root = KMLParser.parseKML(at: url) else {
            return []
        }
        
        return []
    }

    
}


