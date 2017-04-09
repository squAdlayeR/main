//
//  RouteDesignerViewController.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/8/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class RouteDesignerViewController: UIViewController {
    
    let placesClient = GMSPlacesClient()
    let routeDesignerModel = RouteDesignerModel()
    let TESTING = true // IF TRUE, WILL DO CHECKREP
    
    // Constants
    // Threshold is how far a tap point can be away from a marker or a line
    // Range Of Query defines how far away the starting and ending points can be for a query in meters
    let threshold = 35.0
    let similarityThreshold = 0.001
    let currentLocationText = "Current Location"
    let checkpointDefaultDescription = ""
    let checkpointDefaultName = "Checkpoint"
    
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
    var selectingLayerRoute = false
    var selectingGpsRoute = false
    var selectedRoute = false
    
    // Map, Marker and Lines
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    var markers = [GMSMarker]()
    var lines = [GMSPolyline]()
    var googleRouteMarkers = [GMSMarker]()
    var layerRoutesMarkers = [[GMSMarker]]()
    var layerRoutesLines = [[GMSPolyline]]()
    var gpsRoutesMarkers = [[GMSMarker]]()
    var gpsRoutesLines = [[GMSPolyline]]()
    var historyOfMarkers = [[GMSMarker]]()
    
    // Info Window for Tapped Marker
    var tappedMarker = GMSMarker()
    var infoWindow = MarkerPopupView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    @IBOutlet weak var loadingLayerRoutesIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadingGpsRoutesIcon: UIActivityIndicatorView!

    // Segue
    var importedURL: URL?
    var importedRoutes: [Route]?
    var importedSearchDestination: String?

    func checkRepMarkersAndLines(aMarkers: [GMSMarker], aLines: [GMSPolyline]) -> Bool {
        if aMarkers.isEmpty {
            return true
        }
        var from = aMarkers[0].position
        for idx in 1..<aMarkers.count {
            let line = aLines[idx]
            if line.path == nil {
                return false
            }
            if line.path!.count() != 2 {
                return false
            }
            if line.path!.coordinate(at: 0).latitude != from.latitude || line.path!.coordinate(at: 0).longitude != from.longitude {
                return false
            }
            if line.path!.coordinate(at: 1).latitude != aMarkers[idx].position.latitude || line.path!.coordinate(at: 1).longitude != aMarkers[idx].position.longitude {
                return false
            }
            from = aMarkers[idx].position
        }
        return true
    }
    
    func checkRep() -> Bool {
        if markers.count != lines.count {
            return false
        }
        assert(checkRepMarkersAndLines(aMarkers: markers, aLines: lines))
        if layerRoutesMarkers.count != layerRoutesLines.count {
            return false
        }
        for idx in 0..<layerRoutesMarkers.count {
            if layerRoutesMarkers[idx].count != layerRoutesLines[idx].count {
                return false
            }
            assert(checkRepMarkersAndLines(aMarkers: layerRoutesMarkers[idx], aLines: layerRoutesLines[idx]))
        }
        if gpsRoutesMarkers.count != gpsRoutesLines.count {
            return false
        }
        for idx in 0..<gpsRoutesMarkers.count {
            if gpsRoutesMarkers[idx].count != gpsRoutesLines[idx].count {
                return false
            }
            assert(checkRepMarkersAndLines(aMarkers: gpsRoutesMarkers[idx], aLines: gpsRoutesLines[idx]))
        }
        return true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        initializeMap()

        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        sourceBar.returnKeyType = UIReturnKeyType.done
        sourceBar.delegate = self
        searchBar.text = importedSearchDestination
        
        addPanGesture()
        addTapCurrentLocationGesture()
        
        historyOfMarkers.append(markers)
        stopLoadingLayerRoutesAnimation()
        stopLoadingGpsRoutesAnimation()
        
        if let importedURL = importedURL {
            handleOpenUrl(url: importedURL)
        }
        
        if let importedRoutes = importedRoutes {
            load(routes: importedRoutes)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func initializeMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 1.2950584,
                                              longitude: 103.7716573,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.consumesGesturesInView = true;
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view.insertSubview(mapView, at: 0)
        mapView.isHidden = true
        mapView.settings.scrollGestures = true
        mapView.settings.consumesGesturesInView = false
    }
    
    @IBOutlet weak var sourceBar: UITextField!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var googleRouteButton: UIButton!
    @IBOutlet weak var layerRoutesButton: UIButton!
    @IBOutlet weak var gpsRoutesButton: UIButton!
    @IBOutlet weak var currentLocationIcon: UIImageView!
    
    func handleOpenUrl(url: URL) {
        // load route here.
        do {
            let routes = try GPXManager.load(with: url)
            load(routes: routes)
        } catch {
            showAlertMessage(message: "Fail to load the routes.")
        }
    }
    
    func load(routes: [Route]) {
        // load routes
        for route in routes {
            if route.checkPoints.count < 2 { continue }
            var oneMarkers = [GMSMarker]()
            var oneLines = [GMSPolyline]()
            var from = CLLocationCoordinate2D(latitude: route.source!.latitude, longitude: route.source!.longitude)
            for checkpoint in route.checkPoints {
                let to = CLLocationCoordinate2D(latitude: checkpoint.latitude, longitude: checkpoint.longitude)
                self.addMarker(coordinate: to, at: oneMarkers.count, isControlPoint: checkpoint.isControlPoint, using: &oneMarkers, show: true)
                self.addLine(from: from, to: to, at: oneLines.count, using: &oneLines, show: true)
                from = to
            }
            self.layerRoutesMarkers.append(oneMarkers)
            self.layerRoutesLines.append(oneLines)
        }
    }
    
    @IBAction func export(_ sender: Any) {
        let alert = UIAlertController(title: "Name of Route", message: "Enter a Unique Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Route Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Export", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text != nil && textField.text != "") {
                let route = Route(textField.text!)
                let source = self.usingCurrentLocationAsSource ? self.myLocation!.coordinate : self.mySource
                route.append(CheckPoint(source!.latitude, source!.longitude, self.checkpointDefaultName, self.checkpointDefaultDescription, true))
                for marker in self.markers {
                    let markerData = marker.userData as! CheckPoint
                    route.append(markerData)
                }
                self.share(routes: [route])
            } else {
                let resultAlert = UIAlertController(title: "Save Failed", message: "Please give a name to your route", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if TESTING { assert(checkRep()) }
        if historyOfMarkers.count > 1 {
            _ = historyOfMarkers.popLast()
            removeAllMarkersAndLines()
            for (idx, marker) in historyOfMarkers.last!.enumerated() {
                let markerData = marker.userData as! CheckPoint
                addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: idx)
            }
        }
        if TESTING { assert(checkRep()) }
    }
    
    @IBAction func save(_ sender: Any) {
        let alert = UIAlertController(title: "Name of Route", message: "Enter a Unique Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Route Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if (textField.text != nil && textField.text != "") {
                let route = Route(textField.text!)
                route.append(CheckPoint(self.source!.latitude, self.source!.longitude, self.checkpointDefaultName, self.checkpointDefaultDescription, true))
                for marker in self.markers {
                    let markerData = marker.userData as! CheckPoint
                    route.append(markerData)
                }
                do {
                    let url = try GPXManager.save(name: route.name, image: self.viewCapture(view: self.mapView))
                    route.setImage(path: url.absoluteString)
                } catch {
                }
                // TODO: separate local storage and server
                self.routeDesignerModel.saveToLocal(route: route)
                self.routeDesignerModel.saveToDB(route: route)
                
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
                placeAutocomplete(query: searchBar.text!) {(results, error) -> Void in
                    if error != nil {
                        self.cantFindDestinationLocation()
                        return
                    }
                    if let results = results {
                        if results.isEmpty {
                            self.cantFindDestinationLocation()
                            return
                        }
                        var description = results[0].attributedPrimaryText.string
                        if results[0].attributedSecondaryText != nil {
                            description += " "
                            description += results[0].attributedSecondaryText!.string
                        }
                        self.startLoadingLayerRoutesAnimation()
                        self.startLoadingGpsRoutesAnimation()
                        self.searchBar.text = description
                        self.getDirections(origin: "\(self.myLocation!.coordinate.latitude) \(self.myLocation!.coordinate.longitude)", destination: description, waypoints: nil, removeAllPoints: true, at: 0, completion: self.getLayerAndGpsRoutesUponCompletionOfGoogle)
                    }
                }
            } else {
                usingCurrentLocationAsSource = false
                placeAutocomplete(query: sourceBar.text!) {(results, error) -> Void in
                    if error != nil {
                        self.cantFindSourceLocation()
                        return
                    }
                    if let results = results {
                        if results.isEmpty {
                            self.cantFindSourceLocation()
                            return
                        }
                        var sourceDescription = results[0].attributedPrimaryText.string
                        if results[0].attributedSecondaryText != nil {
                            sourceDescription += " "
                            sourceDescription += results[0].attributedSecondaryText!.string
                        }
                        self.placeAutocomplete(query: self.searchBar.text!) {(results2, error2) -> Void in
                            if error2 != nil {
                                self.cantFindDestinationLocation()
                                return
                            }
                            if let results2 = results2 {
                                if results2.isEmpty {
                                    self.cantFindDestinationLocation()
                                    return
                                }
                                var destinationDescription = results2[0].attributedPrimaryText.string
                                if results2[0].attributedSecondaryText != nil {
                                    destinationDescription += " "
                                    destinationDescription += results2[0].attributedSecondaryText!.string
                                }
                                self.startLoadingLayerRoutesAnimation()
                                self.startLoadingGpsRoutesAnimation()
                                self.sourceBar.text = sourceDescription
                                self.searchBar.text = destinationDescription
                                self.getDirections(origin: sourceDescription, destination: destinationDescription, waypoints: nil, removeAllPoints: true, at: 0, completion: self.getLayerAndGpsRoutesUponCompletionOfGoogle)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func showGoogleRoute(_ sender: Any) {
        if TESTING { assert(checkRep()) }
        focusOnOneRoute()
        removeAllMarkersAndLines()
        for (idx, marker) in googleRouteMarkers.enumerated() {
            let markerData = marker.userData as! CheckPoint
            addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: idx)
        }
        if TESTING { assert(checkRep()) }
    }
    
    @IBAction func showLayerRoutes(_ sender: Any) {
        if TESTING { assert(checkRep()) }
        removeAllMarkersAndLines()
        if layerRoutesMarkers.count > 1 {
            selectingLayerRoute = true
            selectedRoute = false
        } else {
            selectingLayerRoute = false
            selectedRoute = true
        }
        for layerRoute in layerRoutesMarkers {
            for marker in layerRoute {
                let markerData = marker.userData as! CheckPoint
                if selectingLayerRoute {
                    if markerData.isControlPoint {
                        marker.map = mapView
                        marker.icon = GMSMarker.markerImage(with: .gray)
                    }
                } else {
                    addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: markers.count)
                }
            }
        }
        for layerRoute in layerRoutesLines {
            for line in layerRoute {
                if selectingLayerRoute {
                    line.map = mapView
                    line.strokeColor = .gray
                }
            }
        }
        if TESTING { assert(checkRep()) }
    }
    
    @IBAction func showGpsRoutes(_ sender: Any) {
        
    }
    
    // LOADING ANIMATIONS
    
    func startLoadingLayerRoutesAnimation() {
        layerRoutesButton.isEnabled = false
        loadingLayerRoutesIcon.isHidden = false
        loadingLayerRoutesIcon.startAnimating()
    }
    
    func stopLoadingLayerRoutesAnimation() {
        loadingLayerRoutesIcon.isHidden = true
        loadingLayerRoutesIcon.stopAnimating()
    }
    
    func startLoadingGpsRoutesAnimation() {
        gpsRoutesButton.isEnabled = false
        loadingGpsRoutesIcon.isHidden = false
        loadingGpsRoutesIcon.startAnimating()
    }
    
    func stopLoadingGpsRoutesAnimation() {
        loadingGpsRoutesIcon.isHidden = true
        loadingGpsRoutesIcon.stopAnimating()
    }
    
    // GET LAYER AND GPS ROUTES
    
    func getLayerAndGpsRoutesUponCompletionOfGoogle(result: Bool) {
        if result {
            // Google Route Available
            googleRouteButton.isEnabled = true
            
            let sourceCoord = source!
            let camera = GMSCameraPosition.camera(withLatitude: sourceCoord.latitude,
                                                  longitude: sourceCoord.longitude,
                                                  zoom: zoomLevel)
            mapView.animate(to: camera)
            getLayerRoutesUponCompletionOfGoogle(result: result)
            getGpsRoutesUponCompletionOfGoogle(result: result)
        } else {
            googleRouteButton.isEnabled = false
        }
    }
    
    func addRoutes(routes: [Route], toMarkers aMarkers: inout [[GMSMarker]], toLines aLines: inout [[GMSPolyline]]) {
        for (idx, route) in routes.enumerated() {
            var isSimilar = false
            for index in 0..<idx {
                if GeoUtil.isSimilar(route1: route, route2: routes[index], threshold: self.similarityThreshold) {
                    isSimilar = true
                    break
                }
            }
            if isSimilar {
                continue
            }
            var oneMarkers = [GMSMarker]()
            var oneLines = [GMSPolyline]()
            var from = source!
            for (index, checkpoint) in route.checkPoints.enumerated() {
                let to = CLLocationCoordinate2D(latitude: checkpoint.latitude, longitude: checkpoint.longitude)
                if index + 1 != route.checkPoints.count {
                    addMarker(coordinate: to, at: oneMarkers.count, isControlPoint: checkpoint.isControlPoint, using: &oneMarkers, show: false)
                } else {
                    addMarker(coordinate: to, at: oneMarkers.count, isControlPoint: true, using: &oneMarkers, show: false)
                }
                addLine(from: from, to: to, at: oneLines.count, using: &oneLines, show: false)
                from = to
            }
            aMarkers.append(oneMarkers)
            aLines.append(oneLines)
        }
    }
    
    func getGpsRoutesUponCompletionOfGoogle(result: Bool) {
        if TESTING { assert(checkRep()) }
        if result {
            // Clear Previous GPS Routes
            let sourceCoord = source!
            let destCoord = markers.last!.position
            for idx in 0..<gpsRoutesMarkers.count {
                removeAllMarkersAndLines(usingMarkersList: &gpsRoutesMarkers[idx], usingLinesList: &gpsRoutesLines[idx])
            }
            gpsRoutesMarkers.removeAll()
            gpsRoutesLines.removeAll()
            
            // Get Layer Routes based on source and destination coordinates provided by Google API
            routeDesignerModel.getGpsRoutes(source: GeoPoint(sourceCoord.latitude, sourceCoord.longitude), dest: GeoPoint(destCoord.latitude, destCoord.longitude)) { (gpsRoutes) -> () in
                self.addRoutes(routes: gpsRoutes, toMarkers: &self.gpsRoutesMarkers, toLines: &self.gpsRoutesLines)
                if self.gpsRoutesMarkers.isEmpty {
                    self.gpsRoutesButton.isEnabled = false
                } else {
                    self.gpsRoutesButton.isEnabled = true
                }
                self.stopLoadingGpsRoutesAnimation()
            }
            
        } else {
            stopLoadingGpsRoutesAnimation()
            gpsRoutesButton.isEnabled = false
        }
        if TESTING { assert(checkRep()) }
    }
    
    func getLayerRoutesUponCompletionOfGoogle(result: Bool) {
        if TESTING { assert(checkRep()) }
        if result {
            // Clear Previous Layer Routes
            let sourceCoord = source!
            let destCoord = markers.last!.position
            for idx in 0..<layerRoutesMarkers.count {
                removeAllMarkersAndLines(usingMarkersList: &layerRoutesMarkers[idx], usingLinesList: &layerRoutesLines[idx])
            }
            layerRoutesMarkers.removeAll()
            layerRoutesLines.removeAll()
            
            // Get Layer Routes based on source and destination coordinates provided by Google API
            routeDesignerModel.getLayerRoutes(source: GeoPoint(sourceCoord.latitude, sourceCoord.longitude), dest: GeoPoint(destCoord.latitude, destCoord.longitude)) { (layerRoutes) -> () in
                self.addRoutes(routes: layerRoutes, toMarkers: &self.layerRoutesMarkers, toLines: &self.layerRoutesLines)
                if self.layerRoutesMarkers.isEmpty {
                    self.layerRoutesButton.isEnabled = false
                } else {
                    self.layerRoutesButton.isEnabled = true
                }
                self.stopLoadingLayerRoutesAnimation()
            }
        } else {
            stopLoadingLayerRoutesAnimation()
            layerRoutesButton.isEnabled = false
        }
        if TESTING { assert(checkRep()) }
    }
    
    func selectRoute(coordinate: CLLocationCoordinate2D, forType: Int) {
        let startPoint = mapView.projection.point(for: coordinate)
        switch forType {
        case 0:
            for (idx, layerRoute) in layerRoutesMarkers.enumerated() {
                let typeOfTouch = getTypeOfTouch(from: startPoint, using: layerRoute)
                switch typeOfTouch.0 {
                case 0: continue
                case 1: selectLayerOrGpsRoute(at: idx, usingMarkers: layerRoutesMarkers, usingLines: layerRoutesLines)
                case 2: selectLayerOrGpsRoute(at: idx, usingMarkers: layerRoutesMarkers, usingLines: layerRoutesLines)
                default: continue
                }
            }
        case 1:
            for (idx, layerRoute) in gpsRoutesMarkers.enumerated() {
                let typeOfTouch = getTypeOfTouch(from: startPoint, using: layerRoute)
                switch typeOfTouch.0 {
                case 0: continue
                case 1: selectLayerOrGpsRoute(at: idx, usingMarkers: gpsRoutesMarkers, usingLines: gpsRoutesLines)
                case 2: selectLayerOrGpsRoute(at: idx, usingMarkers: gpsRoutesMarkers, usingLines: gpsRoutesLines)
                default: continue
                }
            }
        default:
            break
        }
    }
    
    func selectLayerOrGpsRoute(at idx: Int, usingMarkers aMarkers: [[GMSMarker]], usingLines aLines: [[GMSPolyline]]) {
        if TESTING { assert(checkRep()) }
        removeAllMarkersAndLines()
        selectedRoute = true
        for (index, route) in aLines.enumerated() {
            for (index2, line) in route.enumerated() {
                if idx == index {
                    line.strokeColor = UIColor.blue
                    let marker = aMarkers[index][index2]
                    let markerData = marker.userData as! CheckPoint
                    marker.icon = GMSMarker.markerImage(with: .red)
                    addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: index2)
                } else {
                    line.strokeColor = UIColor.gray
                    aMarkers[index][index2].icon = GMSMarker.markerImage(with: .gray)
                }
            }
        }
        if TESTING { assert(checkRep()) }
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
    
    func changeStartLocation() {
        if TESTING { assert(checkRep()) }
        if !markers.isEmpty && usingCurrentLocationAsSource {
            removeLine(at: 0)
            addLine(from: myLocation!.coordinate, to: markers[0].position, at: 0)
        }
        if TESTING { assert(checkRep()) }
    }
    
    func focusOnOneRoute() {
        if TESTING { assert(checkRep()) }
        selectingLayerRoute = false
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
        if TESTING { assert(checkRep()) }
    }
    
    // Drag Action
    
    func startDragControlPoint(startPoint: CGPoint, lastControlPointIdx: Int) {
        if TESTING { assert(checkRep()) }
        focusOnOneRoute()
        let deleteIdx = lastControlPointIdx + 1
        var done = false
        while (deleteIdx < markers.count) {
            let deleteData = markers[deleteIdx].userData as! CheckPoint
            if deleteData.isControlPoint {
                if done {
                    break
                } else {
                    deletePoint(at: deleteIdx)
                    done = true
                }
            } else {
                deletePoint(at: deleteIdx)
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
        if TESTING { assert(checkRep()) }
    }
    
    func startDragRoute(startPoint: CGPoint, lastControlPointIdx: Int) {
        if TESTING { assert(checkRep()) }
        focusOnOneRoute()
        let deleteIdx = lastControlPointIdx + 1
        while (deleteIdx < markers.count - 1) {
            let deleteData = markers[deleteIdx].userData as! CheckPoint
            if deleteData.isControlPoint {
                break
            } else {
                deletePoint(at: deleteIdx)
                
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
        if TESTING { assert(checkRep()) }
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
        if TESTING { assert(checkRep()) }
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
                lastControlPointIdx = idx
            }
        }
        lastControlPointIdx = -1
        for (idx, point) in listOfMarkers.enumerated() {
            let pointData = point.userData as! CheckPoint
            let nextPoint = mapView.projection.point(for: CLLocationCoordinate2DMake(pointData.latitude, pointData.longitude))
            let dist = distanceFromPointToLine(point: startPoint, fromLineSegmentBetween: prevPoint, and: nextPoint)
            if  dist <= threshold {
                return (2, lastControlPointIdx)
            }
            prevPoint = nextPoint
            if pointData.isControlPoint {
                lastControlPointIdx = idx
            }
        }
        if TESTING { assert(checkRep()) }
        return (0, lastControlPointIdx)
    }
    
    func modifyToGoogleRoute() {
        if TESTING { assert(checkRep()) }
        guard let dragIdx = dragMarkerIdx else {
            return
        }
        let originString = dragIdx <= 0 ? "\(source!.latitude) \(source!.longitude)" : "\(markers[dragIdx-1].position.latitude) \(markers[dragIdx-1].position.longitude)"
        let middleString = "\(markers[dragIdx].position.latitude) \(markers[dragIdx].position.longitude)"
        if dragIdx == markers.count - 1 {
            removeLine(at: lines.count-1)
            removeMarker(at: markers.count-1)
            getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx) { (result) -> () in
                if result {
                    self.historyOfMarkers.append(self.markers)
                }
            }
        } else {
            let destinationString = "\(markers[dragIdx+1].position.latitude) \(markers[dragIdx+1].position.longitude)"
            getDirections(origin: middleString, destination: destinationString, waypoints: nil, removeAllPoints: false, at: dragIdx+1) { (result) -> () in
                self.getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx) { (result2) -> () in
                    if result || result2 {
                        self.historyOfMarkers.append(self.markers)
                    }
                }
            }
        }
        if TESTING { assert(checkRep()) }
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
    
    func endDragMarker() {
        if TESTING { assert(checkRep()) }
        if !mapView.settings.scrollGestures && !manualRouteType {
            modifyToGoogleRoute()
        }
        if !mapView.settings.scrollGestures && manualRouteType {
            historyOfMarkers.append(markers)
        }
        mapView.settings.scrollGestures = true
        mapView.settings.consumesGesturesInView = false
        if TESTING { assert(checkRep()) }
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
            endDragMarker()
        } else {
            draggingMarker(currentPoint: startPoint)
        }
        
    }
    
    @IBAction func toggleRouteType(_ sender: Any) {
        manualRouteType = !manualRouteType
    }
    
    // GOOGLE ROUTING FUNCTION
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>?, removeAllPoints: Bool, at markersIdx: Int, completion: @escaping (_ result: Bool)->()) {
        routeDesignerModel.getDirections(origin: origin, destination: destination, waypoints: waypoints, at: markersIdx) { (result, path) -> () in
            if self.TESTING { assert(self.checkRep()) }
            if result {
                if removeAllPoints {
                    self.removeAllMarkersAndLines()
                }
                
                for idx in 1..<path!.count() {
                    if idx == path!.count() - 1 {
                        if markersIdx + Int(idx-1) >= self.markers.count {
                            self.addPoint(coordinate: path!.coordinate(at: idx), isControlPoint: true, at: markersIdx+Int(idx-1))
                        }
                    } else {
                        self.addPoint(coordinate: path!.coordinate(at: idx), isControlPoint: false, at: markersIdx+Int(idx-1))
                    }
                }
                if removeAllPoints {
                    self.googleRouteMarkers = self.markers
                }
            } else {
                if path == nil {
                    self.cantFindDestinationLocation()
                } else {
                    self.cantHaveSameSourceAndDestination()
                }
            }
            completion(result)
            if self.TESTING { assert(self.checkRep()) }
        }
    }
    
    func cantFindDestinationLocation() {
        showErrorMessage(errorMsg: "We can't find this destination!")
    }
    
    func cantFindSourceLocation() {
        showErrorMessage(errorMsg: "We can't find this source!")
    }
    
    func cantHaveSameSourceAndDestination() {
        showErrorMessage(errorMsg: "Please select different source and destination!")
    }
    
    func showErrorMessage(errorMsg: String) {
        let alertController = UIAlertController(title: "Sorry!", message:
            errorMsg, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // DESIGN HELPER FUNCTIONS
    
    private func withinThreshold(first: CGPoint, second: CGPoint) -> Bool {
        let dist = sqrt((first.x - second.x) * (first.x - second.x) + (first.y - second.y) * (first.y - second.y))
        return Double(dist) <= threshold
    }
    
    private func distanceFromPointToLine(point p: CGPoint, fromLineSegmentBetween l1: CGPoint, and l2: CGPoint) -> Double {
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
    
    func findPreviousControlPoint(at idx: Int) -> Int {
        var cur = idx-1
        while true {
            if cur < 0 {
                return cur
            }
            let markerData = markers[cur].userData as! CheckPoint
            if markerData.isControlPoint {
                return cur
            }
            cur -= 1
        }
    }
    
    func findNextControlPoint(at idx: Int) -> Int {
        var cur = idx+1
        while true {
            if cur >= markers.count {
                return cur
            }
            let markerData = markers[cur].userData as! CheckPoint
            if markerData.isControlPoint {
                return cur
            }
            cur += 1
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
    
    func addPath(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        if TESTING { assert(checkRep()) }
        if manualRouteType {
            addPoint(coordinate: coordinate, isControlPoint: isControlPoint, at: idx)
            historyOfMarkers.append(markers)
        } else {
            let lastPoint = markers.isEmpty ? source! : markers.last!.position
            getDirections(origin: "\(lastPoint.latitude) \(lastPoint.longitude)", destination: "\(coordinate.latitude) \(coordinate.longitude)", waypoints: nil, removeAllPoints: false, at: idx) { (result) -> () in
                if result {
                    self.historyOfMarkers.append(self.markers)
                }
            }
        }
        if TESTING { assert(checkRep()) }
    }
    
    func addPoint(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        if TESTING { assert(checkRep()) }
        if idx >= markers.count {
            var currentLocation = usingCurrentLocationAsSource ? myLocation!.coordinate : coordinate
            if !markers.isEmpty {
                currentLocation = markers.last!.position
            } else {
                mySource = coordinate
            }
            addLine(from: currentLocation, to: coordinate, at: markers.count)
            addMarker(coordinate: coordinate, at: markers.count, isControlPoint: isControlPoint)
        } else if idx >= 0 {
            removeLine(at: idx)
            addLine(from:  coordinate, to: markers[idx].position, at: idx)
            addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint)
            let beforeCoord = idx == 0 ? usingCurrentLocationAsSource ? myLocation!.coordinate : coordinate : markers[idx-1].position
            addLine(from: beforeCoord, to: coordinate, at: idx)
        }
        if TESTING { assert(checkRep()) }
    }
    
    func deletePoint(at idx: Int) {
        if TESTING { assert(checkRep()) }
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
        if TESTING { assert(checkRep()) }
    }
    
    func modifyLine(at idx: Int) {
        if TESTING { assert(checkRep()) }
        if idx >= 0 && idx < lines.count {
            let from = idx == 0 ? source! : markers[idx-1].position
            let to = markers[idx].position
            if manualRouteType {
                removeLine(at: idx)
                addLine(from: from, to: to, at: idx)
            } else {
                getDirections(origin: "\(from.latitude) \(from.longitude)", destination: "\(to.latitude) \(to.longitude)", waypoints: nil, removeAllPoints: false, at: idx) { (result) -> () in
                    // print(result)
                }
            }
        }
        if TESTING { assert(checkRep()) }
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
        if TESTING { assert(checkRep()) }
        for marker in markersList {
            marker.map = nil
        }
        for line in linesList {
            line.map = nil
        }
        markersList.removeAll()
        linesList.removeAll()
        infoWindow.removeFromSuperview()
        if TESTING { assert(checkRep()) }
    }
    
    func removeAllMarkersAndLines() {
        removeAllMarkersAndLines(usingMarkersList: &markers, usingLinesList: &lines)
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
                    distance: 0, superViewController: arViewController)
                checkpointCard.setCheckpointName(checkpoint.name)
                checkpointCard.setCheckpointDescription("Oops! This checkpoint has no specific description.")
                arViewController.checkpointCardControllers.append(CheckpointCardController(checkpoint: checkpoint,
                                                                                           card: checkpointCard))
            }
            if (!markers.isEmpty) {
                arViewController.checkpointCardControllers[0].setSelected(true)
            }
            arViewController.prepareNodes()
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

