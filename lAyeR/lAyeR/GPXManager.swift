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
        let path = try getPath(with: route.name, ext: "gpx")
        let gpx = try GPSTrackerParser.instace.parseRouteToGPX(route: route)
        do {
            try gpx.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            throw GPXError.saveFailure
        }
    }
    
    static func save(name: String, image: UIImage) throws -> URL {
        let path = try getPath(with: name, ext: "png")
        let url = URL(fileURLWithPath: path)
        try UIImagePNGRepresentation(image)?.write(to: url)
        return url
    }
    
    static func delete(routeName: String) -> Bool {
        do {
            let path = try getPath(with: routeName, ext: "gpx")
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    static func delete(url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
    
    static func getPath(with fileName: String, ext: String) throws -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            throw GPXError.noPathFound
        }
        let url = documentDirectory.appendingPathComponent(fileName + "." + ext)
        return url.relativePath
    }
}
