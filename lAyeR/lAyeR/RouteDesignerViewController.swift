import UIKit
import GoogleMaps
import GooglePlaces

class RouteDesignerViewController: UIViewController {
    
    // Constants
    // Threshold is how far a tap point can be away from a marker or a line
    // Range Of Query defines how far away the starting and ending points can be for a query in meters
    let threshold = 35.0
    let rangeOfQuery = 100.0
    let currentLocationText = "Current Location"
    let checkpointDefaultDescription = ""
    let checkpointDefaultName = "Checkpoint"
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    // Location Variables
    var locationManager = CLLocationManager()
    var myLocation: CLLocation?
    var usingCurrentLocationAsSource = true
    var mySource: CLLocationCoordinate2D?
    var source: CLLocationCoordinate2D? {
        get {
            return usingCurrentLocationAsSource ? myLocation!.coordinate : mySource
        }
    }
    
    // State of Dragging
    var dragMarkerIdx: Int?
    
    // State of Editing
    var manualRouteType = true
    var selectingRoute = false
    var selectedRoute = false
    
    // Map, Marker and Lines
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    var markers = [GMSMarker]()
    var lines = [GMSPolyline]()
    var googleRouteMarkers = [GMSMarker]()
    var layerRoutesMarkers = [[GMSMarker]]()
    var layerRoutesLines = [[GMSPolyline]]()
    var historyOfMarkers = [[GMSMarker]]()
    
    // Info Window for Tapped Marker
    var tappedMarker = GMSMarker()
    var infoWindow = MarkerPopupView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
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
        
        // Add the map to the view, hide it until location update.
        view.insertSubview(mapView, at: 0)
        mapView.isHidden = true
        googleRouteButton.isEnabled = false
        layerRoutesButton.isEnabled = false
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        sourceBar.returnKeyType = UIReturnKeyType.done
        sourceBar.delegate = self
        
        mapView.settings.scrollGestures = true
        mapView.settings.consumesGesturesInView = false
        addPanGesture()
        addTapCurrentLocationGesture()
        historyOfMarkers.append(markers)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var sourceBar: UITextField!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var googleRouteButton: UIButton!
    @IBOutlet weak var layerRoutesButton: UIButton!
    @IBOutlet weak var currentLocationIcon: UIImageView!
    
    @IBAction func undo(_ sender: UIButton) {
        if historyOfMarkers.count > 1 {
            _ = historyOfMarkers.popLast()
            removeAllMarkersAndLines()
            for (idx, marker) in historyOfMarkers.last!.enumerated() {
                let markerData = marker.userData as! CheckPoint
                addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: idx)
            }
        }
    }
    
    @IBAction func save(_ sender: Any) {
        let alert = UIAlertController(title: "Name of Route", message: "Enter a Unique Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Route Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text != nil && textField.text != "") {
                let route = Route(textField.text!)
                let source = self.usingCurrentLocationAsSource ? self.myLocation!.coordinate : self.mySource
                route.append(CheckPoint(source!.latitude, source!.longitude, self.checkpointDefaultName, self.checkpointDefaultDescription, true))
                for marker in self.markers {
                    let markerData = marker.userData as! CheckPoint
                    route.append(markerData)
                }
                // TODO: separate local storage and server
                RealmLocalStorageManager.getInstance().saveRoute(route)
                DataServiceManager.instance.addRouteToDatabase(route: route)
                let resultAlert = UIAlertController(title: "Saved Successfully", message: "Congrats", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            } else {
                let resultAlert = UIAlertController(title: "Save Failed", message: "Please give a name to your route", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func search(_ sender: Any) {
        if searchBar.text != nil && searchBar.text != "" && sourceBar.text != nil && sourceBar.text != "" {
            if sourceBar.text! == currentLocationText && myLocation != nil {
                usingCurrentLocationAsSource = true
                getDirections(origin: "\(myLocation!.coordinate.latitude) \(myLocation!.coordinate.longitude)", destination: searchBar.text!, waypoints: nil, removeAllPoints: true, at: 0, completion: getLayerRoutesUponCompletionOfGoogle)
            } else {
                usingCurrentLocationAsSource = false
                getDirections(origin: sourceBar.text!, destination: searchBar.text!, waypoints: nil, removeAllPoints: true, at: 0, completion: getLayerRoutesUponCompletionOfGoogle)
            }
        }
    }
    
    @IBAction func showGoogleRoute(_ sender: Any) {
        focusOnOneRoute()
        removeAllMarkersAndLines()
        for (idx, marker) in googleRouteMarkers.enumerated() {
            let markerData = marker.userData as! CheckPoint
            addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: idx)
        }
    }
    
    @IBAction func showLayerRoutes(_ sender: Any) {
        removeAllMarkersAndLines()
        if layerRoutesMarkers.count > 1 {
            selectingRoute = true
            selectedRoute = false
        } else {
            selectingRoute = false
            selectedRoute = true
        }
        for layerRoute in layerRoutesMarkers {
            for marker in layerRoute {
                let markerData = marker.userData as! CheckPoint
                if markerData.isControlPoint {
                    if selectingRoute {
                        marker.map = mapView
                        marker.icon = GMSMarker.markerImage(with: .gray)
                    } else {
                        addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: markers.count)
                    }
                }
            }
        }
        for layerRoute in layerRoutesLines {
            for line in layerRoute {
                if selectingRoute {
                    line.map = mapView
                    line.strokeColor = .gray
                }
            }
        }
    }
    
    func getLayerRoutesUponCompletionOfGoogle(result: Bool) {
        if result {
            for idx in 0..<layerRoutesMarkers.count {
                removeAllMarkersAndLines(usingMarkersList: &layerRoutesMarkers[idx], usingLinesList: &layerRoutesLines[idx])
            }
            layerRoutesMarkers.removeAll()
            layerRoutesLines.removeAll()
            let sourceCoord = self.usingCurrentLocationAsSource ? self.myLocation!.coordinate : self.mySource
            let destCoord = self.markers.last!.position
            let layerRoutes = RealmLocalStorageManager.getInstance().getRoutes(between: GeoPoint(sourceCoord!.latitude, sourceCoord!.longitude), and: GeoPoint(destCoord.latitude, destCoord.longitude), inRange: self.rangeOfQuery)
            for route in layerRoutes {
                var oneMarkers = [GMSMarker]()
                var oneLines = [GMSPolyline]()
                var from = usingCurrentLocationAsSource ? myLocation!.coordinate : mySource!
                for checkpoint in route.checkPoints {
                    let to = CLLocationCoordinate2D(latitude: checkpoint.latitude, longitude: checkpoint.longitude)
                    addMarker(coordinate: to, at: oneMarkers.count, isControlPoint: checkpoint.isControlPoint, using: &oneMarkers, show: false)
                    addLine(from: from, to: to, at: oneLines.count, using: &oneLines, show: false)
                    from = to
                }
                self.layerRoutesMarkers.append(oneMarkers)
                self.layerRoutesLines.append(oneLines)
            }
            if self.layerRoutesMarkers.isEmpty {
                self.layerRoutesButton.isEnabled = false
            } else {
                self.layerRoutesButton.isEnabled = true
            }
        } else {
            self.layerRoutesButton.isEnabled = false
        }
    }
    
    func selectRoute(coordinate: CLLocationCoordinate2D) {
        let startPoint = mapView.projection.point(for: coordinate)
        for (idx, layerRoute) in layerRoutesMarkers.enumerated() {
            let typeOfTouch = getTypeOfTouch(from: startPoint, using: layerRoute)
            switch typeOfTouch.0 {
            case 0: continue
            case 1: selectLayerRoute(at: idx)
            case 2: selectLayerRoute(at: idx)
            default: continue
            }
        }
    }
    
    func selectLayerRoute(at idx: Int) {
        removeAllMarkersAndLines()
        selectedRoute = true
        for (index, layerRoute) in layerRoutesLines.enumerated() {
            for (index2, line) in layerRoute.enumerated() {
                if idx == index {
                    line.strokeColor = UIColor.blue
                    let marker = layerRoutesMarkers[index][index2]
                    let markerData = marker.userData as! CheckPoint
                    marker.icon = GMSMarker.markerImage(with: .red)
                    addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: index2)
                } else {
                    line.strokeColor = UIColor.gray
                    layerRoutesMarkers[index][index2].icon = GMSMarker.markerImage(with: .gray)
                }
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
    
    func addTapCurrentLocationGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCurrentLocation(gestureRecognizer:)))
        currentLocationIcon.isUserInteractionEnabled = true
        currentLocationIcon.addGestureRecognizer(tapGesture)
    }
    
    func tappedCurrentLocation(gestureRecognizer: UITapGestureRecognizer) {
        sourceBar.text = currentLocationText
    }
    
    func focusOnOneRoute() {
        selectingRoute = false
        for layerRoute in layerRoutesMarkers {
            for marker in layerRoute {
                let markerData = marker.userData as! CheckPoint
                if markerData.isControlPoint {
                    marker.map = nil
                }
            }
        }
        for layerRoute in layerRoutesLines {
            for line in layerRoute {
                line.map = nil
            }
        }
    }
    
    // Drag Action
    
    func startDragControlPoint(startPoint: CGPoint, lastControlPointIdx: Int) {
        focusOnOneRoute()
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
        let prevCoordinate = lastControlPointIdx == -1 ? source! : markers[lastControlPointIdx].position
        
        if deleteIdx < markers.count {
            let nextCoordinate = markers[deleteIdx].position
            removeLine(at: deleteIdx)
            addLine(from: startCoordinate, to: nextCoordinate, at: deleteIdx)
        }
        addMarker(coordinate: startCoordinate, at: deleteIdx, isControlPoint: true)
        addLine(from: prevCoordinate, to: startCoordinate, at: deleteIdx)
        dragMarkerIdx = deleteIdx
        mapView.settings.scrollGestures = false
    }
    
    func startDragRoute(startPoint: CGPoint, lastControlPointIdx: Int) {
        focusOnOneRoute()
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
        let prevCoordinate = lastControlPointIdx == -1 ? source! : markers[lastControlPointIdx].position
        let nextCoordinate = markers[deleteIdx].position
        
        addMarker(coordinate: startCoordinate, at: deleteIdx, isControlPoint: true)
        addLine(from: startCoordinate, to: nextCoordinate, at: deleteIdx)
        addLine(from: prevCoordinate, to: startCoordinate, at: deleteIdx)
        dragMarkerIdx = deleteIdx
        mapView.settings.scrollGestures = false
    }
    
    func startDragMap() {
        mapView.settings.scrollGestures = true
        mapView.settings.consumesGesturesInView = true
        dragMarkerIdx = nil
    }
    
    // returns 1 if touching marker
    // returns 2 if touching line
    // returns 0 otherwise (touching map)
    func getTypeOfTouch(from startPoint: CGPoint, using listOfMarkers: [GMSMarker]) -> (Int, Int) {
        var prevPoint = mapView.projection.point(for: source!)
        var lastControlPointIdx = -1
        for (idx, point) in listOfMarkers.enumerated() {
            let pointData = point.userData as! CheckPoint // Latitude and Longitude
            // convert latitude and longitude into CGPoint for comparison
            let nextPoint = mapView.projection.point(for: CLLocationCoordinate2DMake(pointData.latitude, pointData.longitude))
            if pointData.isControlPoint {
                if withinThreshold(first: startPoint, second: nextPoint) {
                    return (1, lastControlPointIdx)
                }
            }
            let dist = distanceToPoint(point: startPoint, fromLineSegmentBetween: prevPoint, and: nextPoint)
            if  dist <= threshold {
                return (2, lastControlPointIdx)
            }
            prevPoint = nextPoint
            if pointData.isControlPoint {
                lastControlPointIdx = idx
            }
        }
        return (0, lastControlPointIdx)
    }
    
    func modifyToGoogleRoute() {
        guard let dragIdx = dragMarkerIdx else {
            return
        }
        let originString = dragIdx <= 0 ? "\(source!.latitude) \(source!.longitude)" : "\(markers[dragIdx-1].position.latitude) \(markers[dragIdx-1].position.longitude)"
        let middleString = "\(markers[dragIdx].position.latitude) \(markers[dragIdx].position.longitude)"
        if dragIdx == markers.count - 1 {
            removeLine(at: lines.count-1)
            removeMarker(at: markers.count-1)
            getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx) { (result) -> () in
                // print(result)
            }
        } else {
            let destinationString = "\(markers[dragIdx+1].position.latitude) \(markers[dragIdx+1].position.longitude)"
            getDirections(origin: middleString, destination: destinationString, waypoints: nil, removeAllPoints: false, at: dragIdx+1) { (result) -> () in
                // print(result)
            }
            getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx) { (result) -> () in
                // print(result)
            }
        }
    }
    
    func draggingMarker(currentPoint: CGPoint) {
        if let dragIdx = dragMarkerIdx {
            removeMarker(at: dragIdx)
            let currentCoordinate = mapView.projection.coordinate(for: currentPoint)
            addMarker(coordinate: currentCoordinate, at: dragIdx, isControlPoint: true)
            if dragIdx == 0 {
                if dragIdx == markers.count - 1 {
                    removeLine(at: dragIdx)
                    addLine(from: source!, to: currentCoordinate, at: dragIdx)
                } else {
                    removeLine(at: dragIdx)
                    removeLine(at: dragIdx)
                    let nextMarkerData = markers[dragIdx+1].userData as! CheckPoint
                    addLine(from: currentCoordinate, to: CLLocationCoordinate2DMake(nextMarkerData.latitude, nextMarkerData.longitude), at: dragIdx)
                    addLine(from: source!, to: currentCoordinate, at: dragIdx)
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
    
    func panned(gestureRecognizer: UIPanGestureRecognizer) {
        let startPoint = gestureRecognizer.location(in: self.view)
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let typeOfTouch = getTypeOfTouch(from: startPoint, using: markers)
            switch typeOfTouch.0 {
            case 0: startDragMap()
            case 1: startDragControlPoint(startPoint: startPoint, lastControlPointIdx: typeOfTouch.1)
            case 2: startDragRoute(startPoint: startPoint, lastControlPointIdx: typeOfTouch.1)
            default: startDragMap()
            }
        } else if gestureRecognizer.state == UIGestureRecognizerState.ended {
            if !manualRouteType {
                modifyToGoogleRoute()
            }
            if !mapView.settings.scrollGestures && manualRouteType {
                historyOfMarkers.append(markers)
            }
            mapView.settings.scrollGestures = true
            mapView.settings.consumesGesturesInView = false
        } else {
            draggingMarker(currentPoint: startPoint)
        }
        
    }
    
    @IBAction func toggleRouteType(_ sender: Any) {
        manualRouteType = !manualRouteType
    }
    
    // GOOGLE ROUTING FUNCTION
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>?, removeAllPoints: Bool, at markersIdx: Int, completion: @escaping (_ result: Bool)->()) {
        
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
                            for idx in 1..<path.count() {
                                if idx == path.count() - 1 {
                                    if markersIdx + Int(idx-1) >= self.markers.count {
                                        self.addPoint(coordinate: path.coordinate(at: idx), isControlPoint: true, at: markersIdx+Int(idx-1))
                                    }
                                } else {
                                    self.addPoint(coordinate: path.coordinate(at: idx), isControlPoint: false, at: markersIdx+Int(idx-1))
                                }
                            }
                            if removeAllPoints {
                                self.googleRouteMarkers = self.markers
                            }
                            self.googleRouteButton.isEnabled = true
                            completion(true)
                        }
                        else {
                            self.cantFindLocation()
                            completion(false)
                        }
                    }
                    catch {
                        self.cantFindLocation()
                        completion(false)
                    }
                })
            }
            else {
                cantFindLocation()
                completion(false)
            }
        }
        else {
            cantFindLocation()
            completion(false)
        }
    }
    
    func cantFindLocation() {
        let alertController = UIAlertController(title: "Sorry!", message:
            "We can't find this destination!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        googleRouteButton.isEnabled = false
    }
    
    // DESIGN HELPER FUNCTIONS
    
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
    
    // DESIGN HELPER FUNCTIONS
    
    func addPath(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        if manualRouteType {
            addPoint(coordinate: coordinate, isControlPoint: isControlPoint, at: idx)
        } else {
            let lastPoint = markers.isEmpty ? source! : markers.last!.position
            getDirections(origin: "\(lastPoint.latitude) \(lastPoint.longitude)", destination: "\(coordinate.latitude) \(coordinate.longitude)", waypoints: nil, removeAllPoints: false, at: idx) { (result) -> () in
                print(result)
            }
        }
        historyOfMarkers.append(markers)
    }
    
    func addPoint(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        if idx >= markers.count {
            var currentLocation = usingCurrentLocationAsSource ? myLocation!.coordinate : coordinate
            if !markers.isEmpty {
                let pointData = markers.last!.userData as! CheckPoint
                currentLocation = CLLocationCoordinate2D(latitude: pointData.latitude, longitude: pointData.longitude)
            } else {
                mySource = coordinate
            }
            addLine(from: currentLocation, to: coordinate, at: markers.count)
            addMarker(coordinate: coordinate, at: markers.count, isControlPoint: isControlPoint)
        } else {
            removeLine(at: idx)
            addLine(from:  coordinate, to: markers[idx].position, at: idx)
            addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint)
            let beforeCoord = idx == 0 ? usingCurrentLocationAsSource ? myLocation!.coordinate : coordinate : markers[idx-1].position
            addLine(from: beforeCoord, to: coordinate, at: idx)
        }
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
                    addLine(from: source!, to: CLLocationCoordinate2DMake(nextMarkerData.latitude, nextMarkerData.longitude), at: idx)
                    
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
    
    func findIdxInMarkers(of key: CheckPoint) -> Int {
        for (idx, marker) in markers.enumerated() {
            let nextMarkerData = marker.userData as! CheckPoint
            if nextMarkerData == key {
                return idx
            }
        }
        return -1
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool, using markersList: inout [GMSMarker], show: Bool) {
        let marker = GMSMarker(position: coordinate)
        marker.title = checkpointDefaultName
        marker.userData = CheckPoint(coordinate.latitude, coordinate.longitude, marker.title!, "", isControlPoint)
        if isControlPoint && show {
            marker.map = mapView
        }
        markersList.insert(marker, at: idx)
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool) {
        addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint, using: &markers, show: true)
    }
    
    func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int, using linesList: inout [GMSPolyline], show: Bool) {
        let path = GMSMutablePath()
        path.add(from)
        path.add(to)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.geodesic = true
        if show {
            polyline.map = mapView
        }
        linesList.insert(polyline, at: idx)
    }
    
    func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int) {
        addLine(from: from, to: to, at: idx, using: &lines, show: true)
    }
    
    func removeMarker(at idx: Int) {
         if idx >= 0 && idx < markers.count {
            markers[idx].map = nil
            markers.remove(at:idx)
         }
    }
    
    func removeLine(at idx: Int) {
         if idx >= 0 && idx < lines.count {
            lines[idx].map = nil
            lines.remove(at:idx)
         }
    }
    
    func removeAllMarkersAndLines(usingMarkersList markersList: inout [GMSMarker], usingLinesList linesList: inout [GMSPolyline]) {
        for marker in markersList {
            marker.map = nil
        }
        for line in linesList {
            line.map = nil
        }
        markersList.removeAll()
        linesList.removeAll()
        infoWindow.removeFromSuperview()
    }
    
    func removeAllMarkersAndLines() {
        removeAllMarkersAndLines(usingMarkersList: &markers, usingLinesList: &lines)
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
        return false
    }
    
    func deleteButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        if myLocation == nil {
            return
        }
        infoWindow.removeFromSuperview()
        let tappedMarkerData = tappedMarker.userData as! CheckPoint
        let idx = findIdxInMarkers(of: tappedMarkerData)
        deleteMarker(at: idx)
        historyOfMarkers.append(markers)
    }
    
    func addAfterButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        infoWindow.removeFromSuperview()
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
        if selectingRoute {
            selectRoute(coordinate: coordinate)
            if selectedRoute {
                focusOnOneRoute()
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
        if selectingRoute {
            selectRoute(coordinate: coordinate)
        } else {
            addPath(coordinate: coordinate, isControlPoint: true, at: markers.count)
        }
    }
    
    // ---------------- back segue to AR view --------------------//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let arViewController = segue.destination as? ARViewController {
            arViewController.checkpointCardControllers.removeAll()
            for marker in markers {
                guard let checkpoint = marker.userData as? CheckPoint else {
                    break
                }
                let checkpointCard = CheckpointCard(center: CGPoint(x: -100, y: -100),  // for demo only, hide out of screen
                                                    distance: 0, superView: arViewController.view)
                checkpointCard.setCheckpointName(checkpoint.name)
                checkpointCard.setCheckpointDescription("To be specified...")
                arViewController.checkpointCardControllers.append(CheckpointCardController(checkpoint: checkpoint,
                                                                                           card: checkpointCard))
            }
            if (!markers.isEmpty) {
                arViewController.checkpointCardControllers[0].setSelected(true)
            }
            
            //TODO: force update the POI in ARView
        }
    }
}

extension RouteDesignerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

