//
//  MapQueryParser.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import Alamofire

class QueryManager {
    
    /// Plug in completion block to process the json received.
    static func handleServerResponse(_ url: String, completion: @escaping (_ json: [String: Any]) -> ()) {
        Alamofire.request(url).responseJSON { response in
            if let JSON = response.result.value as? [String: Any] {
                completion(JSON)
            }
        }
    }
    
    /// Plug in completion block.
    static func handlePostJSON(_ url: String, _ json: [String: Any], completion: @escaping ()->()) {
        Alamofire.request(url, method: .post, parameters: json, encoding: JSONEncoding.default).responseJSON { response in
            completion()
        }
    }
    
}
