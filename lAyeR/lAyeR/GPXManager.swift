//
//  GPXManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

class GPXManager {
    
    static func load(with url: URL) throws -> [Route] {
        let routes = try GPSTrackerParser.instace.parseGPXToRoute(url: url)
        return routes
    }
    
    /// Cache - if needed else delete after export
    static func save(route: Route) throws {
        let path = try getPath(with: route.name)
        let gpx = try GPSTrackerParser.instace.parseRouteToGPX(route: route)
        do {
            try gpx.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            throw GPXError.saveFailure
        }
    }
    
    static func delete(routeName: String) -> Bool {
        do {
            let path = try getPath(with: routeName)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    static func getPath(with fileName: String) throws -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            throw GPXError.noPathFound
        }
        let url = documentDirectory.appendingPathComponent(fileName + "." + "gpx")
        return url.relativePath
    }
}
