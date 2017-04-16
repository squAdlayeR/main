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
    
    // State of Designing Routes
    var manualRouteType = true
    var selectingLayerRoute = false
    var selectingGpsRoute = false
    var selectedRoute = false
    
    // State of Search
    var selectingSource = false
    var useSourceCoordinates = false
    var useDestCoordinates = false
    var selectingSourceCoordinate = false
    var selectingSearchCoordinate = false
    
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
    
    // save window for save / export
    var storeRoutePopupController: BasicAlertController!
    var optionsPopupController: BasicAlertController!
    
    // Suggested Places for Table View
    var suggestedPlaces = [String]()
    
    // Segue
    var importedURL: URL?
    var importedRoutes: [Route]?
    var importedSearchDestination: String?
    var viewControllerNavigatedFrom:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        initializeMap()
        initializeSearch()
        initializeSuggestedPlaces()
        initializeMarkersAndLines()
        addPanGesture()
        addTapGesture()
        historyOfMarkers.append(markers)
        
        if let importedURL = importedURL {
            initializeOpenUrl(url: importedURL)
        }
        
        if let importedRoutes = importedRoutes {
            initializeRoutes(routes: importedRoutes)
        }
        
        if let importedSearchDestination = importedSearchDestination {
            searchBar.text = importedSearchDestination
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = topBanner.bounds
        
        goButton.layer.cornerRadius = RouteDesignerConstants.goButtonCornerRadius
        goButton.layer.masksToBounds = true
        
        startButton.layer.cornerRadius = RouteDesignerConstants.startButtonCornerRadius
        startButton.layer.masksToBounds = true
        
        topBanner.addSubview(blurView)
        topBanner.sendSubview(toBack: blurView)
        
        initializeButtons()
        initializeBottomBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var topBanner: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
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
    @IBOutlet weak var cancelSearchButton: UIImageView!
    @IBOutlet weak var mostBottomBanner: UIView!
    @IBOutlet weak var undoButton: UIButton!

    
    // ---------------- Initializations --------------------//
    
    private func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    private func initializeMap() {
        // Initialize Camera to random values. Will update later.
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
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: RouteDesignerConstants.mapBottomPadding, right: 0)
    }
    
    private func initializeSearch() {
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        sourceBar.returnKeyType = UIReturnKeyType.done
        sourceBar.delegate = self
        stopLoadingLayerRoutesAnimation()
        stopLoadingGpsRoutesAnimation()
        
        googleRouteButton.isEnabled = false
        layerRoutesButton.isEnabled = false
        gpsRoutesButton.isEnabled = false
    }
    
    private func initializeSuggestedPlaces() {
        suggestedPlacesTableView.delegate =   self
        suggestedPlacesTableView.dataSource =   self
        suggestedPlacesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        selectPlacesView.isHidden = true
    }
    
    private func initializeMarkersAndLines() {
        for marker in markers {
            guard let checkpoint = marker.userData as? CheckPoint else {
                continue
            }
            if checkpoint.isControlPoint {
                marker.map = mapView
            }
        }
        for line in lines {
            line.map = mapView
        }
        undoButton.isEnabled = false
    }
    
    private func initializeOpenUrl(url: URL) {
        // load route here.
        do {
            let routes = try GPXFileManager.instance.load(with: url)
            initializeRoutes(routes: routes)
        } catch {
            showAlertMessage(message: RouteDesignerConstants.failToLoadGpsRoutesText)
        }
    }
    
    func initializeRoutes(routes: [Route]) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        focusOnOneRoute()
        removeAllPoints()
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
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func initializeButtons() {
        gpsRoutesButton.setTitleColor(UIColor.lightGray, for: .disabled)
        layerRoutesButton.setTitleColor(UIColor.lightGray, for: .disabled)
        googleRouteButton.setTitleColor(UIColor.lightGray, for: .disabled)
        undoButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    func initializeBottomBanner() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = mostBottomBanner.bounds
        
        mostBottomBanner.addSubview(blurEffectView)
        mostBottomBanner.sendSubview(toBack: blurEffectView)
    }
    
    // ---------------- Add Gestures --------------------//
    
    func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(gestureRecognizer:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        mapView.isUserInteractionEnabled = true
        mapView.addGestureRecognizer(panGesture)
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCurrentLocation(gestureRecognizer:)))
        currentLocationIcon.isUserInteractionEnabled = true
        currentLocationIcon.addGestureRecognizer(tapGesture)
        
        let cancelSearchTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelSearch(gestureRecognizer:)))
        cancelSearchButton.isUserInteractionEnabled = true
        cancelSearchButton.addGestureRecognizer(cancelSearchTapGesture)
        
        let sourcePinGesture = UITapGestureRecognizer(target: self, action: #selector(tapSourcePin(gestureRecognizer:)))
        sourcePin.isUserInteractionEnabled = true
        sourcePin.addGestureRecognizer(sourcePinGesture)
        sourcePin.alpha = RouteDesignerConstants.pinDeactivatedAlpha
        
        let searchPinGesture = UITapGestureRecognizer(target: self, action: #selector(tapSearchPin(gestureRecognizer:)))
        searchPin.isUserInteractionEnabled = true
        searchPin.addGestureRecognizer(searchPinGesture)
        searchPin.alpha = RouteDesignerConstants.pinDeactivatedAlpha
    }
    
    func tappedCurrentLocation(gestureRecognizer: UITapGestureRecognizer) {
        sourceBar.text = RouteDesignerConstants.currentLocationText
    }
    
    func cancelSearch(gestureRecognizer: UITapGestureRecognizer) {
        self.selectPlacesView.isHidden = true
    }
    
    // ---------------- Pin Gestures --------------------//
    
    func tapSourcePin(gestureRecognizer: UIPanGestureRecognizer) {
        if !selectingSourceCoordinate {
            selectingSourceCoordinate = true
            sourcePin.alpha = RouteDesignerConstants.pinActivatedAlpha
        } else {
            selectingSourceCoordinate = false
            sourcePin.alpha = RouteDesignerConstants.pinDeactivatedAlpha
        }
        selectingSearchCoordinate = false
        searchPin.alpha = RouteDesignerConstants.pinDeactivatedAlpha
    }
    
    func tapSearchPin(gestureRecognizer: UIPanGestureRecognizer) {
        if !selectingSearchCoordinate {
            selectingSearchCoordinate = true
            searchPin.alpha = RouteDesignerConstants.pinActivatedAlpha
        } else {
            selectingSearchCoordinate = false
            searchPin.alpha = RouteDesignerConstants.pinDeactivatedAlpha
        }
        selectingSourceCoordinate = false
        sourcePin.alpha = RouteDesignerConstants.pinDeactivatedAlpha
    }
    
    // ---------------- Undo Last Action and Remove All --------------------//
    
    @IBAction func undo(_ sender: UIButton) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if historyOfMarkers.count > 1 {
            _ = historyOfMarkers.popLast()
            removeAllPoints()
            for (idx, marker) in historyOfMarkers.last!.enumerated() {
                let markerData = marker.userData as! CheckPoint
                addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: idx)
            }
            if historyOfMarkers.count == 1 {
                undoButton.isEnabled = false
            }
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func addToHistory() {
        historyOfMarkers.append(markers)
        undoButton.isEnabled = true
    }
    
    // Leaves Source and Destination Untouched
    @IBAction func removeAll(_ sender: Any) {
        if markers.count > 1 {
            while markers.count > 1 {
                removePoint(at: 0)
            }
            addToHistory()
        }
    }
    
    
    // ---------------- Google Search Functions --------------------//
    
    // Google Search Helper Function
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>?, removeAllPoints: Bool, at markersIdx: Int, completion: @escaping (_ result: Bool)->()) {
        routeDesignerModel.getDirections(origin: origin, destination: destination, waypoints: waypoints, at: markersIdx) { (result, path) -> () in
            if RouteDesignerConstants.testing { assert(self.checkRep()) }
            if result {
                if removeAllPoints {
                    if self.sourceBar.text == RouteDesignerConstants.currentLocationText {
                        self.usingCurrentLocationAsSource = true
                    } else {
                        self.usingCurrentLocationAsSource = false
                    }
                    self.removeAllPoints()
                }
                
                for idx in 1..<path!.count() {
                    if idx == path!.count() - 1 {
                        // Only add last point if the last point exceeds current marker count
                        // If not, that point will already be there, so there is no need to add last point
                        if markersIdx + Int(idx-1) >= self.markers.count {
                            self.addPoint(coordinate: path!.coordinate(at: idx), isControlPoint: true, at: markersIdx+Int(idx-1))
                        }
                    } else {
                        self.addPoint(coordinate: path!.coordinate(at: idx), isControlPoint: false, at: markersIdx+Int(idx-1))
                    }
                }
                self.addControlPointsToMarkers()
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
            if RouteDesignerConstants.testing { assert(self.checkRep()) }
        }
    }
    
    @IBAction func search(_ sender: Any) {
        searchBar.resignFirstResponder()
        sourceBar.resignFirstResponder()
        if searchBar.text != nil && searchBar.text != "" && sourceBar.text != nil && sourceBar.text != "" {
            if sourceBar.text! == RouteDesignerConstants.currentLocationText && myLocation != nil {
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
                                self.selectPlacesInstructionLabel.text = RouteDesignerConstants.selectSourceText
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
                self.selectPlacesInstructionLabel.text = RouteDesignerConstants.selectDestinationText
                self.suggestedPlacesTableView.reloadData()
                self.selectPlacesView.isHidden = false
            }
        }
    }
    
    // ---------------- Layer and GPS Search Functions --------------------//
    
    func getLayerAndGpsRoutesUponCompletionOfGoogle(result: Bool) {
        if result {
            // Google Route Available
            googleRouteButton.isEnabled = true
            addToHistory()
            
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
                if GeoUtil.isSimilar(route1: route, route2: routes[index], threshold: RouteDesignerConstants.routeSimilarityThreshold) {
                    isSimilar = true
                    break
                }
            }
            if isSimilar {
                continue
            }
            var oneMarkers = [GMSMarker]()
            var oneLines = [GMSPolyline]()
            for (index, checkpoint) in route.checkPoints.enumerated() {
                let to = CLLocationCoordinate2D(latitude: checkpoint.latitude, longitude: checkpoint.longitude)
                let markerName = checkpoint.name == "" ? RouteDesignerConstants.checkpointDefaultName : checkpoint.name
                if index + 1 != route.checkPoints.count {
                    addPoint(coordinate: to, isControlPoint: checkpoint.isControlPoint, at: oneMarkers.count, usingMarkersList: &oneMarkers, usingLinesList: &oneLines, show: false, markerName: markerName)
                } else {
                    addPoint(coordinate: to, isControlPoint: true, at: oneMarkers.count, usingMarkersList: &oneMarkers, usingLinesList: &oneLines, show: false, markerName: markerName)
                }
            }
            aMarkers.append(oneMarkers)
            aLines.append(oneLines)
        }
    }
    
    func getGpsRoutesUponCompletionOfGoogle(result: Bool) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if result {
            // Clear Previous GPS Routes
            let sourceCoord = source!
            let destCoord = markers.last!.position
            for idx in 0..<gpsRoutesMarkers.count {
                removeAllPoints(usingMarkersList: &gpsRoutesMarkers[idx], usingLinesList: &gpsRoutesLines[idx])
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
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func getLayerRoutesUponCompletionOfGoogle(result: Bool) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if result {
            // Clear Previous Layer Routes
            let sourceCoord = source!
            let destCoord = markers.last!.position
            for idx in 0..<layerRoutesMarkers.count {
                removeAllPoints(usingMarkersList: &layerRoutesMarkers[idx], usingLinesList: &layerRoutesLines[idx])
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
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    // ---------------- Show Google, Layer and GPS Routes --------------------//
    
    @IBAction func showGoogleRoute(_ sender: Any) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        focusOnOneRoute()
        removeAllPoints()
        for (idx, marker) in googleRouteMarkers.enumerated() {
            let markerData = marker.userData as! CheckPoint
            addPoint(coordinate: marker.position, isControlPoint: markerData.isControlPoint, at: idx)
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    @IBAction func showLayerRoutes(_ sender: Any) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        focusOnOneRoute()
        removeAllPoints()
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
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    @IBAction func showGpsRoutes(_ sender: Any) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        focusOnOneRoute()
        removeAllPoints()
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
                if selectingGpsRoute {
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
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    // ---------------- Change state from selecting route to designing route --------------------//
    
    func focusOnOneRoute() {
        if RouteDesignerConstants.testing { assert(checkRep()) }
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
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    // ---------------- For Map Type --------------------//
    
    func toggleMapType(_ sender: UIButton) {
        switch sender.titleLabel!.text! {
        case RouteDesignerConstants.mapViewText:
            sender.setTitle(RouteDesignerConstants.satelliteViewText, for: .normal)
            mapView.mapType = .satellite
        case RouteDesignerConstants.satelliteViewText:
            sender.setTitle(RouteDesignerConstants.hybridViewText, for: .normal)
            mapView.mapType = .hybrid
        case RouteDesignerConstants.hybridViewText:
            sender.setTitle(RouteDesignerConstants.mapViewText, for: .normal)
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
    
    // ---------------- Pan Action --------------------//
    
    func panned(gestureRecognizer: UIPanGestureRecognizer) {
        let startPoint = gestureRecognizer.location(in: self.view)
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let typeOfTouch = getTypeOfTouch(from: startPoint, using: markers)
            switch typeOfTouch.0 {
            case .touchMap: startDragMap()
            case .touchMarker: startDragControlPoint(startPoint: startPoint, lastControlPointIdx: typeOfTouch.1)
            case .touchLine: startDragRoute(startPoint: startPoint, lastControlPointIdx: typeOfTouch.1)
            }
        } else if gestureRecognizer.state == UIGestureRecognizerState.ended {
            endDragMarker()
        } else {
            draggingMarker(currentPoint: startPoint)
        }
    }
    
    func getTypeOfTouch(from startPoint: CGPoint, using listOfMarkers: [GMSMarker]) -> (RouteDesignerConstants.TypeOfTouch, Int) {
        // Check from most unlikely to most likely touch location
        if RouteDesignerConstants.testing { assert(checkRep()) }
        var prevPoint = mapView.projection.point(for: source!)
        var lastControlPointIdx = -1
        for (idx, point) in listOfMarkers.enumerated() {
            let pointData = point.userData as! CheckPoint // Latitude and Longitude
            // convert latitude and longitude into CGPoint for comparison
            let nextPoint = mapView.projection.point(for: CLLocationCoordinate2DMake(pointData.latitude, pointData.longitude))
            if pointData.isControlPoint {
                if withinThreshold(first: startPoint, second: nextPoint) {
                    return (.touchMarker, lastControlPointIdx)
                }
                lastControlPointIdx = idx
            }
        }
        lastControlPointIdx = -1
        for (idx, point) in listOfMarkers.enumerated() {
            let pointData = point.userData as! CheckPoint
            let nextPoint = mapView.projection.point(for: CLLocationCoordinate2DMake(pointData.latitude, pointData.longitude))
            let dist = distanceFromPointToLine(point: startPoint, fromLineSegmentBetween: prevPoint, and: nextPoint)
            if  dist <= RouteDesignerConstants.tapPixelThreshold {
                return (.touchLine, lastControlPointIdx)
            }
            prevPoint = nextPoint
            if pointData.isControlPoint {
                lastControlPointIdx = idx
            }
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
        return (.touchMap, lastControlPointIdx)
    }
    
    // Helper Functions for Touch
    
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
    
    private func withinThreshold(first: CGPoint, second: CGPoint) -> Bool {
        let dist = sqrt((first.x - second.x) * (first.x - second.x) + (first.y - second.y) * (first.y - second.y))
        return Double(dist) <= RouteDesignerConstants.tapPixelThreshold
    }
    
    // Starting three different types of pan
    
    private func startDragControlPoint(startPoint: CGPoint, lastControlPointIdx: Int) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        focusOnOneRoute()
        let deleteIdx = lastControlPointIdx + 1
        var done = false
        while (deleteIdx < markers.count) {
            let deleteData = markers[deleteIdx].userData as! CheckPoint
            if deleteData.isControlPoint {
                if done {
                    break
                } else {
                    removePoint(at: deleteIdx)
                    done = true
                }
            } else {
                removePoint(at: deleteIdx)
            }
        }
        let startCoordinate = mapView.projection.coordinate(for: startPoint)
        addPoint(coordinate: startCoordinate, isControlPoint: true, at: deleteIdx)
        dragMarkerIdx = deleteIdx
        mapView.settings.scrollGestures = false
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    private func startDragRoute(startPoint: CGPoint, lastControlPointIdx: Int) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        focusOnOneRoute()
        let deleteIdx = lastControlPointIdx + 1
        while (deleteIdx < markers.count - 1) {
            let deleteData = markers[deleteIdx].userData as! CheckPoint
            if deleteData.isControlPoint {
                break
            } else {
                removePoint(at: deleteIdx)
                
            }
        }
        let startCoordinate = mapView.projection.coordinate(for: startPoint)
        addPoint(coordinate: startCoordinate, isControlPoint: true, at: deleteIdx)
        dragMarkerIdx = deleteIdx
        mapView.settings.scrollGestures = false
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    private func startDragMap() {
        mapView.settings.scrollGestures = true
        mapView.settings.consumesGesturesInView = true
        dragMarkerIdx = nil
    }
    
    // In the process of pan
    
    private func draggingMarker(currentPoint: CGPoint) {
        if let dragIdx = dragMarkerIdx {
            let currentCoordinate = mapView.projection.coordinate(for: currentPoint)
            removePoint(at: dragIdx)
            addPoint(coordinate: currentCoordinate, isControlPoint: true, at: dragIdx)
        }
    }
    
    // Ending pan
    
    private func endDragMarker() {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if !mapView.settings.scrollGestures && !manualRouteType {
            modifyToGoogleRoute()
        }
        if !mapView.settings.scrollGestures && manualRouteType {
            addToHistory()
        }
        mapView.settings.scrollGestures = true
        mapView.settings.consumesGesturesInView = false
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    // For final touchups
    
    private func modifyToGoogleRoute() {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        guard let dragIdx = dragMarkerIdx else {
            return
        }
        let originString = dragIdx <= 0 ? "\(source!.latitude) \(source!.longitude)" : "\(markers[dragIdx-1].position.latitude) \(markers[dragIdx-1].position.longitude)"
        let middleString = "\(markers[dragIdx].position.latitude) \(markers[dragIdx].position.longitude)"
        if dragIdx == markers.count - 1 {
            removePoint(at: markers.count-1)
            getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx) { (result) -> () in
                if result {
                    self.addToHistory()
                }
            }
        } else {
            let destinationString = "\(markers[dragIdx+1].position.latitude) \(markers[dragIdx+1].position.longitude)"
            getDirections(origin: middleString, destination: destinationString, waypoints: nil, removeAllPoints: false, at: dragIdx+1) { (result) -> () in
                self.getDirections(origin: originString, destination: middleString, waypoints: nil, removeAllPoints: false, at: dragIdx) { (result2) -> () in
                    if result || result2 {
                        self.addToHistory()
                    }
                }
            }
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    // ---------------- Changing Designing Route Type --------------------//
    
    func toggleRouteType(_ sender: UIButton) {
        if manualRouteType {
            sender.setTitle(RouteDesignerConstants.googleRouteText, for: .normal)
            manualRouteType = false
        } else {
            sender.setTitle(RouteDesignerConstants.manualRouteText, for: .normal)
            manualRouteType = true
        }
    }
    
    // ---------------- Error Messages --------------------//
    
    func cantFindDestinationLocation() {
        showErrorMessage(errorMsg: RouteDesignerConstants.cannotFindDestinationText)
    }
    
    func cantFindSourceLocation() {
        showErrorMessage(errorMsg: RouteDesignerConstants.cannotFindSourceText)
    }
    
    func cantHaveSameSourceAndDestination() {
        showErrorMessage(errorMsg: RouteDesignerConstants.cannotChooseSameSourceAndDestinationText)
    }
    
    private func showErrorMessage(errorMsg: String) {
        let alertController = UIAlertController(title: "Sorry!", message:
            errorMsg, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}



