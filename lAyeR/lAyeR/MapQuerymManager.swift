//
//  MapQueryParser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import Alamofire

class MapQueryParser {
    
    /// test url
    static let googleServerURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=511.1&types=food&name=cruise&key=AIzaSyBT4bqEv5pABPznq2HsPlIuVVcdJXgV3JY"
    static let apiKey = "AIzaSyAxEeB1jYBx9HgghM4IXxxzGIA4p6yjr9s"
    
    /// to be implemented
    static func parseUserRequest() -> String {
        return ""
    }
    
    static func parseServerResponse(_ data: Data) {
        var json: [String: Any]?
        do {
            json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            guard let json = json else {
                print("nil here")
                return //POI()
            }
            guard let results = json["results"] as? [[String: Any]] else {
                return
            }
            let first = results.first
            print(first?["name"])
        } catch {
            print("some error")
        }
        //return POI()
    }
    
    static func parseServerResponse(_ jsonData: Data) -> POI? {
        return nil
    }
    
    static func parsePOI() -> Data {
        return Data()
    }
    
    static func retrieveServerResponse(_ url: String) {
        Alamofire.request(url).responseJSON { response in
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }
}
