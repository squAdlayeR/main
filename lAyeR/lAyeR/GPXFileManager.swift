//
//  GPXManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

/**
 * GPXManager is used to save/load .gpx files.
 */
class GPXFileManager {
    
    static let instance: GPXFileManager = GPXFileManager()
    /// Loads .gpx files with file url into the app.
    /// - Parameters:
    ///     - url: URL: the url to the file 
    /// - Returns: 
    ///     - [Route]: routes contained in the file. 
    /// - Throws: 
    ///     - GPXError.readFailure: gpx read fail error.
    func load(with url: URL) throws -> [Route] {
        let routes = try GPXFileParser.instace.parseGPXToRoute(url: url)
        return routes
    }
    
    /// Saves a route to a .gpx file.
    /// - Parameters:
    ///     - route: Route: the route to save. 
    /// - Throws:
    ///     - GPXError.createFailure: gpx file creation failure. 
    ///     - GPXError.saveFailure: gpx file save failure.
    func save(route: Route) throws {
        let path = try getPath(with: route.name, ext: GPSGPXConstants.gpxExtension)
        let gpx = try GPXFileParser.instace.parseRouteToGPX(route: route)
        do {
            try gpx.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            throw GPXError.saveFailure
        }
    }
    
    /// Saves routes to multiple .gpx files and returns urls of the files.
    /// - Parameters:
    ///     - routes: [Route]: the routes to save.
    /// - Returns:
    ///     - [URL]: the urls of the saved gpx files.
    /// - Throws:
    ///     - GPXError.createFailure: gpx file creation failure.
    ///     - GPXError.saveFailure: gpx file save failure.
    ///     - GPXError.noPathFound: no valid file path found error.
    func save(routes: [Route]) throws -> [URL] {
        var urls: [URL] = []
        for route in routes {
            try save(route: route)
            let path = try getPath(with: route.name, ext: GPSGPXConstants.gpxExtension)
            let url = URL(fileURLWithPath: path)
            urls.append(url)
        }
        return urls
    }
    
    /// Saves a UIImage to a .png file.
    /// - Parameters: 
    ///     - name: String: name given to the image. 
    ///     - image: UIImage: the UIImage to save. 
    /// - Returns:
    ///     - URL: the file url of the saved image.
    /// - Throws:
    ///     - GPXError.noPathFound: no valid file path found.
    ///     - GPXError.saveFailure: file save failure error.
    func save(name: String, image: UIImage) throws -> URL {
        let path = try getPath(with: name, ext: GPSGPXConstants.pngExtension)
        let url = URL(fileURLWithPath: path)
        do {
            try UIImagePNGRepresentation(image)?.write(to: url)
            return url
        } catch {
            throw GPXError.saveFailure
        }
    }
    
    /// Deletes the cache .gpx file with given name.
    /// - Parameters:
    ///     - routeName: String: name of the file.
    func delete(routeName: String) {
        guard let path = try? getPath(with: routeName, ext: GPSGPXConstants.gpxExtension) else {
            return
        }
        try? FileManager.default.removeItem(atPath: path)
    }
    
    /// Deletes the file at given url. 
    /// - Parameters:
    ///     - url: URL: the url of the file.
    func delete(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Returns the file path of the file with given name and extension.
    /// - Parameters:
    ///     - fileName: String: name of the file. 
    ///     - ext: String: extension of the file. 
    /// - Returns:
    ///     - String: the relativePath of the file.
    /// - Throws:
    ///     - GPXError.noPathFound: no valid url path found error.
    func getPath(with fileName: String, ext: String) throws -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else {
            throw GPXError.noPathFound
        }
        let url = documentDirectory.appendingPathComponent("\(fileName).\(ext)")
        return url.absoluteString
    }
}
