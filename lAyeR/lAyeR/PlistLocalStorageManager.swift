//
//  LocalStorageManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation

class PlistLocalStorageManager {
    
    /// Saves the route to Documents folder with given name.
    /// - Parameters: 
    ///     - route: route to save.
    /// - Return: true if saving successfully.
    static func save(_ route: Route) -> Bool {
        let path = getURLRelativePath(route.name)
        let success = NSKeyedArchiver.archiveRootObject(route, toFile: path)
        return success
    }
    
    /// Loads the route data with given name.
    /// - Parameters: 
    ///     - name: given by user.
    /// - Return: the route, nil if load failed.
    static func load(_ name: String) -> Route? {
        let path = getURLRelativePath(name)
        guard let route = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Route else {
            return nil
        }
        return route
    }
    
    /// Deletes the route data with given name.
    /// - Parameters: 
    ///     - name: given by user.
    /// - Return: true if deletion succeeded.
    static func delete(_ name: String) -> Bool {
        let path = getURLRelativePath(name)
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch _ as NSError {
            return false
        }
    }
    
    /// Gets the saved route names.
    /// - Return: names of saved routes, nil if error occurs.
    static func getAvailableRouteNames() -> [String]? {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else { return nil }
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            let savedRouteNames = directoryContents
                .filter { $0.pathExtension == "plist" }
                .map { $0.deletingPathExtension().lastPathComponent }
            return savedRouteNames
        } catch _ as NSError {
            return nil
        }
    }
    
    /// Gets the url relative path to document folder with given name.
    /// - Return: url relative path of the level with given name.
    static func getURLRelativePath(_ name: String) -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else { return "" }
        let url = documentDirectory.appendingPathComponent(name + "." + "plist")
        return url.relativePath
    }

}
