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
    static func handleServerResponse(_ url: String, completion: @escaping (_ json: NSDictionary) -> ()) {
        Alamofire.request(url).responseJSON { response in
            if let JSON = response.result.value as? NSDictionary {
                completion(JSON)
            }
        }
    }
    
    
}
