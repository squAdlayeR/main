//
//  GPSTrackerView.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/7.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

class GPSTrackerViewController: UIViewController {
    
    @IBAction func test(_ sender: Any) {
        do {
            //let gpx = try GPSTrackerParser.instace.parseRouteToGPX(route: Route.testRoute)
            //print(gpx)
            let routes = try GPSTrackerParser.instace.parseGPXToRoute(filePath: "/Users/victoriaduan/Downloads/t.gpx")
            print(routes.first?.name)
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
