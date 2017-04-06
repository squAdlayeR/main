//
//  GPXManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

class GPXManager {
    
    /// TODO: find a way for proper import/export
    func load(with fileName: String) throws -> [Route] {
        let path = try getPath(with: fileName)
        let routes = try GPSTrackerParser.instace.parseGPXToRoute(filePath: path)
        return routes
    }
    
    func save(route: Route) throws -> Bool {
        let path = try getPath(with: route.name)
        let gpx = try GPSTrackerParser.instace.parseRouteToGPX(route: route)
        do {
            try gpx.write(toFile: path, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    func getPath(with fileName: String) throws -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            throw GPXError.noPathFound
        }
        let url = documentDirectory.appendingPathComponent(fileName + "." + "gpx")
        return url.relativePath
    }
}
