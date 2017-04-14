//
//  GPXParser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/6.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

/*
 * GPSTrackerParser is used to parse lAyeR route class into .gpx format
 * string, and parse .gpx file into lAyeR route.
 * This class utilizes iOS-GPX-Framework.
 */
class GPXFileParser {
    
    /// Returns a singleton instance of GPSTrackerParser.
    static let instace = GPXFileParser()
    
    /// Parses Route into GPX string.
    /// - Parameters:
    ///     - route: Route: the route to be parsed.
    /// - Returns:
    ///     - gpx string of the route.
    /// - Throws:
    ///     - GPXError.createFailure: gpx file creation error.
    /// MARK: Currently, lAyeR only supports GPXRoute Tag, as RouteDesigner
    /// displays one route at a time, which is not suitable for GPXTrack 
    /// and GPXTrackSegments representation.
    func parseRouteToGPX(route: Route) throws -> String {
        guard let root = GPXRoot(creator: fileCreator) else {
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
    
    /// Parses GPX file into Routes.
    /// - Parameters:
    ///     - url: URL: the file url to open the GPX file.
    /// - Returns:
    ///     - [Route]: routes contained in the gpx file.
    /// - Throws: 
    ///     - GPXError.readFailure: gpx file read error.
    func parseGPXToRoute(url: URL) throws -> [Route] {
        guard let root = GPXParser.parseGPX(at: url) else {
            throw GPXError.readFailure
        }
        guard let gpxRoutes = root.routes as? [GPXRoute] else {
            return []
        }
        var routes: [Route] = []
        for gpxRoute in gpxRoutes {
            let route = Route(gpxRoute.name)
            let points = gpxRoute.routepoints as? [GPXRoutePoint] ?? []
            for point in points {
                let lat = point.latitude
                let lon = point.longitude
                let name = point.name ?? defaultPointName
                let desc = point.desc ?? ""
                let isControlPoint = point.comment == true.description ? true: false
                let checkPoint = CheckPoint(Double(lat), Double(lon), name, desc, isControlPoint)
                route.append(checkPoint)
            }
            routes.append(route)
        }
        return routes
    }
    
}


