import UIKit
import GoogleMaps
import GooglePlaces

class RouteDesignerViewController: UIViewController {
    
    // GOOGLE PLACES AUTOCOMPLETE
    // var resultsViewController: GMSAutocompleteResultsViewController?
    // var searchController: UISearchController?
    // var resultView: UITextView?
    
    // For tapped marker
    var tappedMarker = GMSMarker()
    var infoWindow = MarkerPopupView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    var afterMarkerTapped = false
    
    @IBOutlet weak var searchBar: UITextField!
    var locationManager = CLLocationManager()
    var myLocation: CLLocation?
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    var checkPointNum = 1
    var markers = [GMSMarker]()
    var lines = [GMSPolyline]()
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: 1.2950584,
                                              longitude: 103.7716573,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.consumesGesturesInView = true;
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapType = .hybrid
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        //mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.insertSubview(mapView, at: 0)
        mapView.isHidden = true
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        
        // GOOGLE PLACES AUTOCOMPLETE
        // resultsViewController = GMSAutocompleteResultsViewController()
        // resultsViewController?.delegate = self
        //
        // searchController = UISearchController(searchResultsController: resultsViewController)
        // searchController?.searchResultsUpdater = resultsViewController
        //
        // let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
        //
        // subView.addSubview((searchController?.searchBar)!)
        // view.addSubview(subView)
        // searchController?.searchBar.sizeToFit()
        // searchController?.hidesNavigationBarDuringPresentation = false
        //
        // // When UISearchController presents the results view, present it in
        // // this view controller, not one further up the chain.
        // definesPresentationContext = true
    }
    
    func oneFunc(_ status: String, _ success: Bool) {}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>?, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&mode=walking"
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                print(directionsURLString)
                directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                let directionsURL = NSURL(string: directionsURLString)
                DispatchQueue.main.async( execute: { () -> Void in
                    let directionsData = NSData(contentsOf: directionsURL! as URL)
                    do{
                        let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            self.removeAllMarkersAndLines()
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                            
                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                            
                            // let originAddress = legs[0]["start_address"] as! String
                            // let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                            
                            // let originMarker = GMSMarker(position: self.originCoordinate)
                            // originMarker.map = self.mapView
                            // originMarker.icon = UIImage(named: "mapIcon")
                            // originMarker.title = originAddress
                            
                            // let destinationMarker = GMSMarker(position: self.destinationCoordinate)
                            // destinationMarker.map = self.mapView
                            // destinationMarker.icon = UIImage(named: "mapIcon")
                            // destinationMarker.title = destinationAddress
                            
                            if waypoints != nil && waypoints!.count > 0 {
                                for waypoint in waypoints! {
                                    let lat: Double = (waypoint.components(separatedBy: ",")[0] as NSString).doubleValue
                                    let lng: Double = (waypoint.components(separatedBy: ",")[1] as NSString).doubleValue
                                    
                                    let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                                    marker.map = self.mapView
                                    // marker.icon = UIImage(named: "flag")
                                    
                                }
                            }
                            
                            let route = self.overviewPolyline["points"] as! String
                            
                            let path: GMSPath = GMSPath(fromEncodedPath: route)!
                            for idx in 0..<path.count() {
                                self.addPoint(coordinate: path.coordinate(at: idx))
                            }
                            // let routePolyline = GMSPolyline(path: path)
                            // routePolyline.map = self.mapView
                            // routePolyline.strokeColor = UIColor.blue
                            // routePolyline.strokeWidth = 3.0
                        }
                        else {
                            self.cantFindLocation()
                        }
                    }
                    catch {
                        self.cantFindLocation()
                    }
                })
            }
            else {
                cantFindLocation()
            }
        }
        else {
            cantFindLocation()
        }
    }
    
    func cantFindLocation() {
        let alertController = UIAlertController(title: "Sorry!", message:
            "We can't find this destination!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func findIdx(of key: CheckPoint) -> Int {
        for (idx, marker) in markers.enumerated() {
            let nextMarkerData = marker.userData as! CheckPoint
            if nextMarkerData == key {
                return idx
            }
        }
        return -1
    }
    
    func addPoint(coordinate: CLLocationCoordinate2D) {
        if currentLocation != nil {
            if afterMarkerTapped {
                let tappedMarkerData = tappedMarker.userData as! CheckPoint
                let newIdx = findIdx(of: tappedMarkerData) + 1
                addMarker(coordinate: coordinate, at: newIdx)
                
                // Draw path
                removeLine(at: newIdx)
                if newIdx != markers.count - 1 {
                    let nextMarkerData = markers[newIdx+1].userData as! CheckPoint
                    addLine(from:  coordinate, to: CLLocationCoordinate2DMake(nextMarkerData.latitude, nextMarkerData.longitude), at: newIdx)
                }
                addLine(from: CLLocationCoordinate2DMake(tappedMarkerData.latitude, tappedMarkerData.longitude), to: coordinate, at: newIdx)
                
                tappedMarker = markers[newIdx]
            } else {
                let marker = GMSMarker(position: coordinate)
                marker.title = "Checkpoint"
                marker.userData = CheckPoint(coordinate.latitude, coordinate.longitude, marker.title!)
                // marker.icon = UIImage(named: "flag")
                checkPointNum += 1
                marker.map = mapView
                markers.append(marker)
                
                // Draw path
                let path = GMSMutablePath()
                path.addLatitude(currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
                path.addLatitude(coordinate.latitude, longitude: coordinate.longitude)
                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 5.0
                polyline.geodesic = true
                polyline.map = mapView
                lines.append(polyline)
                currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
        }
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int) {
        let marker = GMSMarker(position: coordinate)
        marker.title = "Checkpoint"
        // marker.icon = UIImage(named: "flag")
        marker.userData = CheckPoint(coordinate.latitude, coordinate.longitude, marker.title!)
        checkPointNum += 1
        marker.map = mapView
        markers.insert(marker, at: idx)
        // for nextIdx in idx+1..<markers.count {
        //     let newMarkersData = markers[nextIdx].userData as! CheckPoint
        //     newMarkersData.name = "Checkpoint"
        //     markers[nextIdx].userData = newMarkersData
        // }
    }
    
    func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int) {
        let path = GMSMutablePath()
        path.addLatitude(from.latitude, longitude: from.longitude)
        path.addLatitude(to.latitude, longitude: to.longitude)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.geodesic = true
        polyline.map = mapView
        lines.insert(polyline, at: idx)
    }
    
    func removeMarker(at idx: Int) {
        if idx >= 0 && idx < markers.count {
            // need to update current location
            if idx == markers.count - 1 {
                if idx == 0 {
                    currentLocation = myLocation
                } else {
                    let lastMarkerData = markers[idx-1].userData as! CheckPoint
                    currentLocation = CLLocation(latitude: lastMarkerData.latitude, longitude: lastMarkerData.longitude)
                }
            }
            markers[idx].map = nil
            markers.remove(at:idx)
            // for nextIdx in idx..<markers.count {
            //     var newMarkersData = markers[nextIdx].userData as! CheckPoint
            //     newMarkersData.name = "Checkpoint"
            //     markers[nextIdx].userData = newMarkersData
            // }
            checkPointNum -= 1
        }
    }
    
    func removeLine(at idx: Int) {
        if idx >= 0 && idx < lines.count {
            lines[idx].map = nil
            lines.remove(at:idx)
        }
    }
    
    func removeAllMarkersAndLines() {
        for marker in markers {
            marker.map = nil
        }
        for line in lines {
            line.map = nil
        }
        markers.removeAll()
        lines.removeAll()
        currentLocation = myLocation
        checkPointNum = 1
        infoWindow.removeFromSuperview()
    }
    
    
}

extension RouteDesignerViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
            currentLocation = location
            myLocation = location
            locationManager.stopUpdatingLocation()
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            // locationManager.startUpdatingLocation()
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension RouteDesignerViewController: GMSMapViewDelegate {
    
    //empty the default infowindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let location = CLLocationCoordinate2D(latitude: (marker.userData as! CheckPoint).latitude, longitude: (marker.userData as! CheckPoint).longitude)
        
        tappedMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = MarkerPopupView(frame: CGRect(x: 0, y: 0, width: 150, height: 110))
        infoWindow.label.text = (marker.userData as! CheckPoint).name
        var centerPoint = mapView.projection.point(for: location)
        centerPoint.y = centerPoint.y - 95
        infoWindow.center = centerPoint
        infoWindow.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(gestureRecognizer:)), for: .touchUpInside)
        infoWindow.addAfterButton.addTarget(self, action: #selector(addAfterButtonTapped(gestureRecognizer:)), for: .touchUpInside)
        self.view.addSubview(infoWindow)
        
        afterMarkerTapped = false
        
        // Remember to return false
        // so marker event is still handled by delegate
        return false
    }
    
    func deleteButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        if myLocation == nil {
            return
        }
        infoWindow.removeFromSuperview()
        let tappedMarkerData = tappedMarker.userData as! CheckPoint
        let idx = findIdx(of: tappedMarkerData)
        if idx >= 0 && idx < markers.count {
            // 3 Cases
            if idx == 0 {
                if idx == markers.count - 1 {
                    removeMarker(at: idx)
                    removeLine(at: idx)
                } else {
                    removeMarker(at: idx)
                    removeLine(at: idx)
                    removeLine(at: idx)
                    let nextMarkerData = markers[idx].userData as! CheckPoint
                    addLine(from: myLocation!.coordinate, to: CLLocationCoordinate2DMake(nextMarkerData.latitude, nextMarkerData.longitude), at: idx)
                    
                }
            } else if idx == markers.count - 1 {
                removeMarker(at: idx)
                removeLine(at: idx)
            } else {
                removeMarker(at: idx)
                removeLine(at: idx)
                removeLine(at: idx)
                let nextMarkerData = markers[idx].userData as! CheckPoint
                let previousMarkerData = markers[idx-1].userData as! CheckPoint
                addLine(from: CLLocationCoordinate2DMake(previousMarkerData.latitude, previousMarkerData.longitude), to: CLLocationCoordinate2DMake(nextMarkerData.latitude, nextMarkerData.longitude), at: idx)
            }
        }
    }
    
    func addAfterButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        infoWindow.removeFromSuperview()
        afterMarkerTapped = true
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (tappedMarker.userData != nil){
            let location = CLLocationCoordinate2D(latitude: (tappedMarker.userData as! CheckPoint).latitude, longitude: (tappedMarker.userData as! CheckPoint).longitude)
            var centerPoint = mapView.projection.point(for: location)
            centerPoint.y = centerPoint.y - 95
            infoWindow.center = centerPoint
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
        addPoint(coordinate: coordinate)
        print("Long Tapped at coordinate: " + String(coordinate.latitude) + " "
            + String(coordinate.longitude))
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
        print("Tapped at coordinate: " + String(coordinate.latitude) + " "
            + String(coordinate.longitude))
    }
}

extension RouteDesignerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if myLocation != nil && textField.text != nil {
            getDirections(origin: "\(myLocation!.coordinate.latitude) \(myLocation!.coordinate.longitude)", destination: textField.text!, waypoints: nil, completionHandler: oneFunc)
        }
        return false
    }
}

// GOOGLE PLACES AUTOCOMPLETE
// extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
//    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
//                           didAutocompleteWith place: GMSPlace) {
//        searchController?.isActive = false
//        // Do something with the selected place.
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
//    }
//
//    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
//                           didFailAutocompleteWithError error: Error){
//        // TODO: handle the error.
//        print("Error: ", error.localizedDescription)
//    }
//
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
// }
