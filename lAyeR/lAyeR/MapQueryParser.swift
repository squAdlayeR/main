//
//  MapQueryParser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

class MapQueryParser {
    
    /// test url
    static let googleServerURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AIzaSyBT4bqEv5pABPznq2HsPlIuVVcdJXgV3JY"
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
    
    func submitAction(sender: AnyObject) {
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        let parameters = ["name": "test", "password": "test"] as Dictionary<String, String>
        
        //create the url with URL
        let url = URL(string: "http://myServerName.com/api")! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }

}
