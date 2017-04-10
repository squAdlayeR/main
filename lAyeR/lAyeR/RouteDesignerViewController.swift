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
    // Similarity Threshold defines whether or not two routes that are too similar are both shown
    let threshold = 45.0
    let similarityThreshold = 0.001
    let currentLocationText = "Current Location"
    let checkpointDefaultDescription = ""
    let checkpointDefaultName = "Checkpoint"
    let selectDestinationText = "Please select destination"
    let selectSourceText = "Please select source"
    
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
    var sourceText = ""
    
    // State of Dragging
    var dragMarkerIdx: Int?
    var sourcePinLocation: CGPoint?
    var searchPinLocation: CGPoint?
    var useSourceCoordinates = false
    var useDestCoordinates = false
    
    // State of Designing Routes
    var manualRouteType = true
    var selectingLayerRoute = false
    var selectingGpsRoute = false
    var selectedRoute = false
    
    // State of Search
    var selectingSource = false
    
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
    
    // Suggested Places for Table View
    var suggestedPlaces = [String]()
    
    // Segue
    var importedURL: URL?
    var importedRoutes: [Route]?
    var importedSearchDestination: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        initializeMap()
        initializeSearch()
        initializeSuggestedPlaces()
        
        addPanGesture()
        addTapCurrentLocationGesture()
        
        historyOfMarkers.append(markers)
        
        if let importedURL = importedURL {
            handleOpenUrl(url: importedURL)
        }
        
        if let importedRoutes = importedRoutes {
            load(routes: importedRoutes)
        }
        
        if let importedSearchDestination = importedSearchDestination {
            searchBar.text = importedSearchDestination
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        getPinLocations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var loadingLayerRoutesIcon: UIActivityIndicatorView!
    @IBOutlet weak var loadingGpsRoutesIcon: UIActivityIndicatorView!
    @IBOutlet weak var sourceBar: UITextField!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var googleRouteButton: UIButton!
    @IBOutlet weak var layerRoutesButton: UIButton!
    @IBOutlet weak var gpsRoutesButton: UIButton!
    @IBOutlet weak var currentLocationIcon: UIImageView!
    @IBOutlet weak var sourcePin: UIImageView!
    @IBOutlet weak var searchPin: UIImageView!
    
    // ---------------- Check Rep --------------------//
    
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
    
    // ---------------- Initializations --------------------//
    
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
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
    }
    
    func initializeSearch() {
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        sourceBar.returnKeyType = UIReturnKeyType.done
        sourceBar.delegate = self
        stopLoadingLayerRoutesAnimation()
        stopLoadingGpsRoutesAnimation()
    }
    
    func initializeSuggestedPlaces() {
        suggestedPlacesTableView.delegate =   self
        suggestedPlacesTableView.dataSource =   self
        suggestedPlacesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        selectPlacesView.isHidden = true
    }
    
    // ---------------- Add Gestures --------------------//
    
    func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(gestureRecognizer:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(panGesture)
        
        let sourcePinGesture = UIPanGestureRecognizer(target: self, action: #selector(dragSourcePin(gestureRecognizer:)))
        sourcePinGesture.minimumNumberOfTouches = 1
        sourcePinGesture.maximumNumberOfTouches = 1
        sourcePin.isUserInteractionEnabled = true
        sourcePin.addGestureRecognizer(sourcePinGesture)
        
        let searchPinGesture = UIPanGestureRecognizer(target: self, action: #selector(dragSearchPin(gestureRecognizer:)))
        searchPinGesture.minimumNumberOfTouches = 1
        searchPinGesture.maximumNumberOfTouches = 1
        searchPin.isUserInteractionEnabled = true
        searchPin.addGestureRecognizer(searchPinGesture)
    }
    
    func getPinLocations() {
        sourcePinLocation = sourcePin.center
        searchPinLocation = searchPin.center
    }
    
    func addTapCurrentLocationGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCurrentLocation(gestureRecognizer:)))
        currentLocationIcon.isUserInteractionEnabled = true
        currentLocationIcon.addGestureRecognizer(tapGesture)
    }
    
    func tappedCurrentLocation(gestureRecognizer: UITapGestureRecognizer) {
        sourceBar.text = currentLocationText
    }
    
    // ---------------- Pin Gestures --------------------//
    
    func dragSourcePin(gestureRecognizer: UIPanGestureRecognizer) {
        if (gestureRecognizer.state != .ended) && (gestureRecognizer.state != .failed) {
            gestureRecognizer.view?.center = gestureRecognizer.location(in: self.view)
        } else {
            useSourceCoordinates = true
            let point = gestureRecognizer.location(in: self.view)
            let coordinate = mapView.projection.coordinate(for: point)
            sourceBar.text = "\(coordinate.latitude) \(coordinate.longitude)"
            sourcePin.center = sourcePinLocation!
        }
    }
    
    func dragSearchPin(gestureRecognizer: UIPanGestureRecognizer) {
        if (gestureRecognizer.state != .ended) && (gestureRecognizer.state != .failed) {
            gestureRecognizer.view?.center = gestureRecognizer.location(in: self.view)
        } else {
            useDestCoordinates = true
            let point = gestureRecognizer.location(in: self.view)
            let coordinate = mapView.projection.coordinate(for: point)
            searchBar.text = "\(coordinate.latitude) \(coordinate.longitude)"
            searchPin.center = searchPinLocation!
        }
    }
    
    // ---------------- GPX --------------------//
    
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
        if TESTING { assert(checkRep()) }
        focusOnOneRoute()
        removeAllMarkersAndLines()
        if !routes.isEmpty {
            if routes[0].checkPoints.count < 2 { return }
            usingCurrentLocationAsSource = false
            for (idx, checkpoint) in routes[0].checkPoints.enumerated() {
                addPoint(coordinate: CLLocationCoordinate2D(latitude: checkpoint.latitude, longitude: checkpoint.longitude), isControlPoint: checkpoint.isControlPoint, at: idx)
            }
            
            // Shift Map to see Loaded Route
            let camera = GMSCameraPosition.camera(withLatitude: routes[0].checkPoints[0].latitude,
                                                  longitude: routes[0].checkPoints[0].longitude,
                                                  zoom: zoomLevel)
            mapView.animate(to: camera)
        }
        if TESTING { assert(checkRep()) }
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
                route.append(CheckPoint(self.source!.latitude, self.source!.longitude, self.checkpointDefaultName, self.checkpointDefaultDescription, true))
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
    
    // ---------------- Undo Last Action --------------------//
    
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
    
    // ---------------- Save Routes (to local storage and db) --------------------//
    
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
    
    // ---------------- Main Search Functions --------------------//
    
    @IBAction func search(_ sender: Any) {
        searchBar.resignFirstResponder()
        sourceBar.resignFirstResponder()
        if searchBar.text != nil && searchBar.text != "" && sourceBar.text != nil && sourceBar.text != "" {
            if sourceBar.text! == currentLocationText && myLocation != nil {
                usingCurrentLocationAsSource = true
                if useDestCoordinates {
                    self.sourceText = "\(self.myLocation!.coordinate.latitude) \(self.myLocation!.coordinate.longitude)"
                    self.startSearch(destination: searchBar.text!)
                } else {
                    placeAutocomplete(query: searchBar.text!) {(results, error) -> Void in
                        if error != nil {
                            self.cantFindDestinationLocation()
                            return
                        }
                        self.sourceText = "\(self.myLocation!.coordinate.latitude) \(self.myLocation!.coordinate.longitude)"
                        self.dealWithSuggestedDestinations(results: results)
                    }
                }
            } else {
                usingCurrentLocationAsSource = false
                if useSourceCoordinates {
                    self.sourceText = sourceBar.text!
                    if useDestCoordinates {
                        self.startSearch(destination: searchBar.text!)
                    } else {
                        placeAutocomplete(query: searchBar.text!) {(results, error) -> Void in
                            if error != nil {
                                self.cantFindDestinationLocation()
                                return
                            }
                            self.dealWithSuggestedDestinations(results: results)
                        }
                    }
                } else {
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
                            if results.count == 1 {
                                self.sourceText = results[0].attributedPrimaryText.string
                                if results[0].attributedSecondaryText != nil {
                                    self.sourceText += " "
                                    self.sourceText += results[0].attributedSecondaryText!.string
                                }
                                self.sourceBar.text = self.sourceText
                                self.placeAutocomplete(query: self.searchBar.text!) {(results2, error2) -> Void in
                                    if error2 != nil {
                                        self.cantFindDestinationLocation()
                                        return
                                    }
                                    self.dealWithSuggestedDestinations(results: results2)
                                }
                            } else {
                                self.suggestedPlaces.removeAll()
                                self.selectingSource = true
                                for result in results {
                                    var description = result.attributedPrimaryText.string
                                    if result.attributedSecondaryText != nil {
                                        description += " "
                                        description += result.attributedSecondaryText!.string
                                    }
                                    self.suggestedPlaces.append(description)
                                }
                                self.selectPlacesInstructionLabel.text = self.selectSourceText
                                self.suggestedPlacesTableView.reloadData()
                                self.selectPlacesView.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startSearch(destination: String) {
        self.startLoadingLayerRoutesAnimation()
        self.startLoadingGpsRoutesAnimation()
        self.searchBar.text = destination
        self.getDirections(origin: self.sourceText, destination: destination, waypoints: nil, removeAllPoints: true, at: 0, completion: self.getLayerAndGpsRoutesUponCompletionOfGoogle)
    }
    
    func dealWithSuggestedDestinations(results: [GMSAutocompletePrediction]?) {
        if let results = results {
            if results.isEmpty {
                self.cantFindDestinationLocation()
                return
            }
            if results.count == 1 {
                var description = results[0].attributedPrimaryText.string
                if results[0].attributedSecondaryText != nil {
                    description += " "
                    description += results[0].attributedSecondaryText!.string
                }
                self.startSearch(destination: description)
            } else {
                self.suggestedPlaces.removeAll()
                self.selectingSource = false
                for result in results {
                    var description = result.attributedPrimaryText.string
                    if result.attributedSecondaryText != nil {
                        description += " "
                        description += result.attributedSecondaryText!.string
                    }
                    self.suggestedPlaces.append(description)
                }
                self.selectPlacesInstructionLabel.text = self.selectDestinationText
                self.suggestedPlacesTableView.reloadData()
                self.selectPlacesView.isHidden = false
            }
        }
    }
    
    // ---------------- For Showing Different Types of Routes --------------------//
    
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
        if selectingLayerRoute {
            for layerRoute in layerRoutesLines {
                for line in layerRoute {
                    line.map = mapView
                    line.strokeColor = .gray
                }
            }
        }
        if TESTING { assert(checkRep()) }
    }
    
    @IBAction func showGpsRoutes(_ sender: Any) {
        if TESTING { assert(checkRep()) }
        removeAllMarkersAndLines()
        if gpsRoutesMarkers.count > 1 {
            selectingGpsRoute = true
            selectedRoute = false
        } else {
            selectingGpsRoute = false
            selectedRoute = true
        }
        for gpsRoute in gpsRoutesMarkers {
            for marker in gpsRoute {
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
        if selectingGpsRoute {
            for gpsRoute in gpsRoutesLines {
                for line in gpsRoute {
                    line.map = mapView
                    line.strokeColor = .gray
                }
            }
        }
        if TESTING { assert(checkRep()) }
    }
    
    // ---------------- For Map Type --------------------//
    
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBAction func toggleMapType(_ sender: Any) {
        switch mapTypeButton.titleLabel!.text! {
        case "Map View":
            mapTypeButton.setTitle("Satellite View", for: .normal)
            mapView.mapType = .satellite
        case "Satellite View":
            mapTypeButton.setTitle("Hybrid View", for: .normal)
            mapView.mapType = .hybrid
        case "Hybrid View":
            mapTypeButton.setTitle("Map View", for: .normal)
            mapView.mapType = .normal
        default:
            break
        }
    }
    
    // ---------------- For Table View --------------------//
    
    @IBOutlet weak var selectPlacesInstructionLabel: UILabel!
    @IBOutlet weak var selectPlacesView: UIView!
    @IBOutlet weak var suggestedPlacesTableView: UITableView!
    
    
    // ---------------- Loading Animations --------------------//
    
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
    
    // ---------------- Get Layer and GPS Routes --------------------//
    
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
    
    // ---------------- Change from selecting route to designing route --------------------//
    
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
        selectingGpsRoute = false
        for gpsRoute in gpsRoutesMarkers {
            for marker in gpsRoute {
                let markerData = marker.userData as! CheckPoint
                if markerData.isControlPoint {
                    marker.map = nil
                }
            }
        }
        for gpsRoute in gpsRoutesLines {
            for line in gpsRoute {
                line.map = nil
            }
        }
        if TESTING { assert(checkRep()) }
    }
    
    // ---------------- Pan Action --------------------//
    
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
    
    // ---------------- Google Directions Helper Function --------------------//
    
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
    
    // ---------------- Error Messages --------------------//
    
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
}

extension RouteDesignerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sourceBar {
            useSourceCoordinates = false
        } else if textField == searchBar {
            useDestCoordinates = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

