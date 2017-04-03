import UIKit
import GoogleMaps
import GooglePlaces

class RouteDesignerViewController: UIViewController {
    
    var manualRouteType = true
    let threshold = 35.0
    var dragMarkerIdx: Int?
    
    // For tapped marker
    var tappedMarker = GMSMarker()
    var infoWindow = MarkerPopupView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    @IBOutlet weak var searchBar: UITextField!
    var locationManager = CLLocationManager()
    var myLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    var checkPointNum = 1
    var markers = [GMSMarker]()
    var lines = [GMSPolyline]()
    var historyOfMarkers = [[GMSMarker]]()
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    @IBAction func undo(_ sender: UIButton) {
        if (historyOfMarkers.count > 1) {
            _ = historyOfMarkers.popLast()
            removeAllMarkersAndLines()
            for (idx, marker) in historyOfMarkers.last!.enumerated() {
                let markerData = marker.userData as! CheckPoint
                addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: idx)
            }
        }
    }
    
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
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        // Add the map to the view, hide it until we've got a location update.
        view.insertSubview(mapView, at: 0)
        mapView.isHidden = true
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        
        mapView.settings.scrollGestures = true
        mapView.settings.consumesGesturesInView = false
        addPanGesture()
        historyOfMarkers.append(markers)
    }
    
    private func withinThreshold(first: CGPoint, second: CGPoint) -> Bool {
        let dist = sqrt((first.x - second.x) * (first.x - second.x) + (first.y - second.y) * (first.y - second.y))
        return Double(dist) <= threshold
    }
    
    private func distanceToPoint(point p: CGPoint, fromLineSegmentBetween l1: CGPoint, and l2: CGPoint) -> Double {
        let a = p.x - l1.x
        let b = p.y - l1.y
        let c = l2.x - l1.x
        let d = l2.y - l1.y
        
        let dot = a * c + b * d
        let lenSq = c * c + d * d
        let param = dot / lenSq
        
        var xx:CGFloat!
        var yy:CGFloat!
        
        if param < 0 || (l1.x == l2.x && l1.y == l2.y) {
            xx = l1.x
            yy = l1.y
        } else if (param > 1) {
            xx = l2.x
            yy = l2.y
        } else {
            xx = l1.x + param * c
            yy = l1.y + param * d
        }
        
        let dx = Double(p.x - xx)
        let dy = Double(p.y - yy)
        
        return sqrt(dx * dx + dy * dy)
    }
    
    func deleteMarker(at idx: Int) {
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
    
    func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(gestureRecognizer:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(panGesture)
    }
    
    func panned(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let startPoint = gestureRecognizer.location(in: self.view) // CGPoint
            var prevPoint = mapView.projection.point(for: myLocation!.coordinate)
            var lastControlPointIdx = -1
            for (idx, point) in markers.enumerated() {
                let pointData = point.userData as! CheckPoint // Latitude and Longitude
                // convert latitude and longitude into CGPoint for comparison
                let nextPoint = mapView.projection.point(for: CLLocationCoordinate2DMake(pointData.latitude, pointData.longitude))
                if pointData.isControlPoint {
                    if withinThreshold(first: startPoint, second: nextPoint) {
                        // Case 1: Dragging Control Point
                        let deleteIdx = lastControlPointIdx + 1
                        var done = false
                        while (deleteIdx < markers.count) {
                            let deleteData = markers[deleteIdx].userData as! CheckPoint
                            if deleteData.isControlPoint {
                                if done {
                                    break
                                } else {
                                    deleteMarker(at: deleteIdx)
                                    done = true
                                }
                            } else {
                                deleteMarker(at: deleteIdx)
                            }
                        }
                        let startCoordinate = mapView.projection.coordinate(for: startPoint)
                        let prevCoordinate = lastControlPointIdx == -1 ? myLocation!.coordinate : markers[lastControlPointIdx].position
                        
                        if deleteIdx < markers.count {
                            let nextCoordinate = markers[deleteIdx].position
                            removeLine(at: deleteIdx)
                            addLine(from: startCoordinate, to: nextCoordinate, at: deleteIdx)
                        }
                        addMarker(coordinate: startCoordinate, at: deleteIdx, isControlPoint: true)
                        addLine(from: prevCoordinate, to: startCoordinate, at: deleteIdx)
                        dragMarkerIdx = deleteIdx
                        mapView.settings.scrollGestures = false
                        print("SIZE1: \(lines.count) | \(markers.count)")
                        return
                    }
                }
                let dist = distanceToPoint(point: startPoint, fromLineSegmentBetween: prevPoint, and: nextPoint)
                if  dist <= threshold {
                    // Case 2: Dragging Route
                    let deleteIdx = lastControlPointIdx + 1
                    while (deleteIdx < markers.count - 1) {
                        let deleteData = markers[deleteIdx].userData as! CheckPoint
                        if deleteData.isControlPoint {
                            break
                        } else {
                            deleteMarker(at: deleteIdx)
                            
                        }
                    }
                    removeLine(at: deleteIdx)
                    let startCoordinate = mapView.projection.coordinate(for: startPoint)
                    let prevCoordinate = lastControlPointIdx == -1 ? myLocation!.coordinate : markers[lastControlPointIdx].position
                    let nextCoordinate = markers[deleteIdx].position
                    
                    addMarker(coordinate: startCoordinate, at: deleteIdx, isControlPoint: true)
                    addLine(from: startCoordinate, to: nextCoordinate, at: deleteIdx)
                    addLine(from: prevCoordinate, to: startCoordinate, at: deleteIdx)
                    dragMarkerIdx = deleteIdx
                    mapView.settings.scrollGestures = false
                    print("SIZE2: \(lines.count) | \(markers.count)")
                    return
                }
                prevPoint = nextPoint
                if pointData.isControlPoint {
                    lastControlPointIdx = idx
                }
            }
            
            // Case 3: Panning Map
            mapView.settings.scrollGestures = true
            mapView.settings.consumesGesturesInView = true
            dragMarkerIdx = nil
        } else if gestureRecognizer.state == UIGestureRecognizerState.ended {
            if !manualRouteType {
                if let dragIdx = dragMarkerIdx {
                    let originString = dragIdx <= 0 ? "\(myLocation!.coordinate.latitude) \(myLocation!.coordinate.longitude)" : "\(markers[dragIdx-1].position.latitude) \(markers[dragIdx-1].position.longitude)"
                    let middleString = "\(markers[dragIdx].position.latitude) \(markers[dragIdx].position.longitude)"
                    if dragIdx == markers.count - 1 {
                        removeLine(at: lines.count-1)
                        removeMarker(at: markers.count-1)
                        getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx)
                        return
                    }
                    let destinationString = "\(markers[dragIdx+1].position.latitude) \(markers[dragIdx+1].position.longitude)"
                    print (destinationString)
                    print (originString)
                    print (middleString)
                    // removeMarker(at: dragIdx+1)
                    // removeLine(at: dragIdx+1)
                    getDirections(origin: middleString, destination: destinationString, waypoints: nil, removeAllPoints: false, at: dragIdx+1)
                    // removeMarker(at: dragIdx)
                    // removeLine(at: dragIdx)
                    // let waypoints = [middleString]
                    getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx)
                }
            }
            if !mapView.settings.scrollGestures {
                historyOfMarkers.append(markers)
            }
            mapView.settings.scrollGestures = true
            mapView.settings.consumesGesturesInView = false
        } else { // ongoing
            if let dragIdx = dragMarkerIdx {
                removeMarker(at: dragIdx)
                let currentPoint = gestureRecognizer.location(in: self.view)
                let currentCoordinate = mapView.projection.coordinate(for: currentPoint)
                addMarker(coordinate: currentCoordinate, at: dragIdx, isControlPoint: true)
                if dragIdx == 0 {
                    if dragIdx == markers.count - 1 {
                        removeLine(at: dragIdx)
                        addLine(from: myLocation!.coordinate, to: currentCoordinate, at: dragIdx)
                    } else {
                        removeLine(at: dragIdx)
                        removeLine(at: dragIdx)
                        let nextMarkerData = markers[dragIdx+1].userData as! CheckPoint
                        addLine(from: currentCoordinate, to: CLLocationCoordinate2DMake(nextMarkerData.latitude, nextMarkerData.longitude), at: dragIdx)
                        addLine(from: myLocation!.coordinate, to: currentCoordinate, at: dragIdx)
                    }
                } else if dragIdx == markers.count - 1 {
                    removeLine(at: dragIdx)
                    let previousMarkerData = markers[dragIdx-1].userData as! CheckPoint
                    addLine(from: CLLocationCoordinate2DMake(previousMarkerData.latitude, previousMarkerData.longitude), to: currentCoordinate, at: dragIdx)
                } else {
                    removeLine(at: dragIdx)
                    removeLine(at: dragIdx)
                    let nextMarkerData = markers[dragIdx+1].userData as! CheckPoint
                    let previousMarkerData = markers[dragIdx-1].userData as! CheckPoint
                    addLine(from: currentCoordinate, to: CLLocationCoordinate2DMake(nextMarkerData.latitude, nextMarkerData.longitude), at: dragIdx)
                    addLine(from: CLLocationCoordinate2DMake(previousMarkerData.latitude, previousMarkerData.longitude), to: currentCoordinate, at: dragIdx)
                }
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleRouteType(_ sender: Any) {
        manualRouteType = !manualRouteType
    }
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>?, removeAllPoints: Bool, at markersIdx: Int) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&mode=walking"
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                directionsURLString = directionsURLString.addingPercentEscapes(using: String.Encoding.utf8)!
                let directionsURL = NSURL(string: directionsURLString)
                DispatchQueue.main.async( execute: { () -> Void in
                    let directionsData = NSData(contentsOf: directionsURL! as URL)
                    do{
                        let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            if removeAllPoints {
                                self.removeAllMarkersAndLines()
                            }
                            let selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            let overviewPolyline = selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                            
                            let route = overviewPolyline["points"] as! String
                            
                            let path: GMSPath = GMSPath(fromEncodedPath: route)!
                            print (path.count())
                            for idx in 1..<path.count() {
                                print ("COORDINATE: \(path.coordinate(at:idx))")
                                if idx == path.count() - 1 {
                                    if markersIdx + Int(idx-1) >= self.markers.count {
                                        self.addPoint(coordinate: path.coordinate(at: idx), isControlPoint: true, at: markersIdx+Int(idx-1))
                                    }
                                } else {
                                    self.addPoint(coordinate: path.coordinate(at: idx), isControlPoint: false, at: markersIdx+Int(idx-1))
                                }
                            }
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
    
    func addPath(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        if manualRouteType {
            addPoint(coordinate: coordinate, isControlPoint: isControlPoint, at: idx)
        } else {
            let lastPoint = markers.isEmpty ? myLocation!.coordinate : markers.last!.position
            getDirections(origin: "\(lastPoint.latitude) \(lastPoint.longitude)", destination: "\(coordinate.latitude) \(coordinate.longitude)", waypoints: nil, removeAllPoints: false, at: idx)
        }
    }
    
    func addPoint(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        if idx >= markers.count {
            var currentLocation = myLocation!.coordinate
            if !markers.isEmpty {
                let pointData = markers.last!.userData as! CheckPoint
                currentLocation = CLLocationCoordinate2D(latitude: pointData.latitude, longitude: pointData.longitude)
            }
            addLine(from: currentLocation, to: coordinate, at: markers.count)
            addMarker(coordinate: coordinate, at: markers.count, isControlPoint: isControlPoint)
        } else {
            removeLine(at: idx)
            addLine(from:  coordinate, to: markers[idx].position, at: idx)
            addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint)
            let beforeCoord = idx == 0 ? myLocation!.coordinate : markers[idx-1].position
            addLine(from: beforeCoord, to: coordinate, at: idx)
        }
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool) {
        let marker = GMSMarker(position: coordinate)
        marker.title = "Checkpoint"
        marker.userData = CheckPoint(coordinate.latitude, coordinate.longitude, marker.title!, isControlPoint)
        checkPointNum += 1
        if isControlPoint {
            marker.map = mapView
        }
        marker.isDraggable = true
        markers.insert(marker, at: idx)
    }
    
    func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int) {
        print("ADDING LINE")
        let path = GMSMutablePath()
        path.add(from)
        path.add(to)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.geodesic = true
        polyline.map = mapView
        lines.insert(polyline, at: idx)
    }
    
    func removeMarker(at idx: Int) {
        // if idx >= 0 && idx < markers.count {
            markers[idx].map = nil
            markers.remove(at:idx)
            checkPointNum -= 1
        // }
    }
    
    func removeLine(at idx: Int) {
        // if idx >= 0 && idx < lines.count {
            lines[idx].map = nil
            lines.remove(at:idx)
        // }
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
        checkPointNum = 1
        infoWindow.removeFromSuperview()
    }
    
    
}

extension RouteDesignerViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
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
        
//        afterMarkerTapped = false
        
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
        deleteMarker(at: idx)
        historyOfMarkers.append(markers)
    }
    
    func addAfterButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        infoWindow.removeFromSuperview()
//        afterMarkerTapped = true
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
        infoWindow.removeFromSuperview()    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
        addPath(coordinate: coordinate, isControlPoint: true, at: markers.count)
        historyOfMarkers.append(markers)
    }
    
    // ---------------- back and forth segue --------------------//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Setting.routeDesignerToARSegueIdentifier {
            guard let arViewController = segue.destination as? ARViewController else {
                return
            }
            for marker in markers {
                guard let checkpoint = marker.userData as? CheckPoint else {
                    break
                }
                let checkpointCard = CheckpointViewController(center: CGPoint.zero,
                                                              distance: 0, superView: arViewController.view)
                checkpointCard.setCheckpointName(checkpoint.name)
                checkpointCard.setCheckpointDescription("To be specified...")
                arViewController.checkpointCardPairs.append((checkpoint, checkpointCard))
            }
            //TODO: force update the POI in ARView
        }
    }
    
    @IBAction func unwindSegueToRouteDesigner(segue: UIStoryboardSegue) {}
}

extension RouteDesignerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if myLocation != nil && textField.text != nil && textField.text != "" {
            getDirections(origin: "\(myLocation!.coordinate.latitude) \(myLocation!.coordinate.longitude)", destination: textField.text!, waypoints: nil, removeAllPoints: true, at: 0)
        }
        return false
    }
}

