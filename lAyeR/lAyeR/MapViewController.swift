//
//  MapViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/10.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Alamofire
import GooglePlaces
import GoogleMaps

class MapViewController: UIViewController {
    
    var route: [NSManagedObject] = []

    var placesClient: GMSPlacesClient?
    let locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation?
    var mapViewDelegate: MapViewDelegate = MapViewDelegate()
    
    // Instantiate a pair of UILabels in Interface Builder
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    // Test
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = mapViewDelegate
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func test(_ json: [String: Any]) {
        let pois = Parser.parseJSONToPOIs(json)
        print(pois.count)
        for poi in pois {
            print(poi.name)
        }
    }
    
    // Test
    @IBAction func getLocation(_ sender: Any) {
        //test()
        guard let currentLocation = mapViewDelegate.userLocation else {
            return
        }
        let request = Parser.parsePOISearchRequest(500, "food", currentLocation)
        QueryManager.handleServerResponse(request, completion: test)
        //save(name: "what", location: mapViewDelegate.userLocation!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func save(name: String, location: CLLocation) {
//        
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//        
//        // 1
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//        
//        // 2
//        let entity =
//            NSEntityDescription.entity(forEntityName: "CheckPoint",
//                                       in: managedContext)!
//        
//        let checkPoint = NSManagedObject(entity: entity,
//                                     insertInto: managedContext)
//        
//        // 3
//        checkPoint.setValue(name, forKeyPath: "name")
//        checkPoint.setValue(location.coordinate.latitude, forKey: "latitude")
//        checkPoint.setValue(location.coordinate.longitude, forKey: "longtitude")
//        checkPoint.setValue(location.altitude, forKey: "altitude")
//        
//        // 4
//        do {
//            try managedContext.save()
//            route.append(checkPoint)
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        //1
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//        
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//        
//        //2
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "CheckPoint")
//        
//        //3
//        do {
//            route = try managedContext.fetch(fetchRequest)
//            print(route.first?.value(forKeyPath: "name"))
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//    }
    
}
