//
//  TestViewController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 8/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps

/**
 This class is designed specifiecally for a mini map view. You can use this 
 controller to call out a mini map into the application view by
 1. create a new MiniMapViewController by calling `let mapController = MiniMapViewController()`
 2. presents the map by calling mapController.prepareMiniMapView(inside: XXX)
 */
class MiniMapViewController: UIViewController, GMSMapViewDelegate {
    
    // The main map view
    private(set) var mapView: GMSMapView!
    
    // Defines geo manager for location queries
    private var geoManager = GeoManager.getInstance()
    
    // See whether the mini map is open or not
    private var isExpanded = false
    
    // Defines the checkpoints that will be shown on the minimap
    private var route: Route = Route(MiniMapConstants.initialRouteName) {
        didSet { drawPath() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMap()
    }
    
    /// Initializes the mini map
    private func initializeMap() {
        prepareMap()
        stylizeGMap()
        settingMap()
    }
    
    /// Prepares the map view with initial settings and stylings.
    /// Retrieves the current user location and centralize user in the minimap
    private func prepareMap() {
        let currentLocation = geoManager.getLastUpdatedUserPoint()
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                              longitude: currentLocation.longitude,
                                              zoom: MiniMapConstants.zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.animate(to: camera)
        view.addSubview(mapView)
    }
    
    /// Changes the styling of the google map, which includes:
    /// - the overall styling through json provided by google
    /// - alpha of the map
    private func stylizeGMap() {
        mapView.mapStyle = try? GMSMapStyle(jsonString: MiniMapConstants.kMapStyleNight)
        mapView.alpha = MiniMapConstants.alpha
    }
    
    /// Change the overall map settings
    /// Mainly disable all the interactions
    private func settingMap() {
        mapView.settings.myLocationButton = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.settings.setAllGesturesEnabled(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* Below are public interactions */
    
    /// Updates the current location to be displayed on the minimap
    /// - Parameter currentLocation: the current location of the user, represented by a geo point
    func updateMiniMap(with currentLocation: GeoPoint) {
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                                     longitude: currentLocation.longitude,
                                                     zoom: MiniMapConstants.zoomLevel))
    }
    
    /// Prepares the display of the view of the view contoller.
    /// - Parameter superView: the super view of the controller.
    func prepareMiniMapView(inside superView: UIView) {
        let superViewWidth = superView.bounds.width
        let mapViewFrame = CGRect(x: 0, y: 0,
                                  width: superViewWidth * MiniMapConstants.sizePercentage,
                                  height: superViewWidth * MiniMapConstants.sizePercentage)
        let center = CGPoint(x: superViewWidth - mapViewFrame.width / 2 - MiniMapConstants.paddingRight,
                             y: mapViewFrame.height / 2 + MiniMapConstants.paddingTop)
        view.frame = mapViewFrame
        view.center = center
        view.layer.zPosition = MiniMapConstants.zPozition
        view.layer.cornerRadius = MiniMapConstants.borderRadius
        view.layer.masksToBounds = true
        superView.addSubview(view)
    }
    
    /// Draws the path that is directing to the destination
    /// Force unwrap is used here because we have checked size of route before
    func drawPath() {
        mapView.clear()
        guard route.size > 0 else { return }
        let clUserPoint = getCLLocation(of: geoManager.getLastUpdatedUserPoint())
        createPath(from: clUserPoint, to: getCLLocation(of: route.checkPoints.first!))
        for index in 1 ..< route.size {
            let from = getCLLocation(of: route.checkPoints[index - 1])
            let to = getCLLocation(of: route.checkPoints[index])
            createPath(from: from, to: to)
        }
    }
    
    /// Gets the CL location of a check point
    /// - Parameter checkpoint: the check point that is to get location
    /// - Returns: the corresponding CL location
    private func getCLLocation(of geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    /// Creates a path between point one and point two.
    /// - Parameters:
    ///     - pointOne: the first check point
    ///     - pointTwo: the second check point
    private func createPath(from pointOne: CLLocationCoordinate2D, to pointTwo: CLLocationCoordinate2D) {
        let path = GMSMutablePath()
        path.add(pointOne)
        path.add(pointTwo)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = MiniMapConstants.strokeWidth
        polyline.strokeColor = MiniMapConstants.strokeColor
        polyline.geodesic = true
        polyline.map = mapView
    }
    
    /// Toggles the size of the mini map
    func toggleMiniMapSize() {
        if isExpanded {
            shrinkMiniMap()
            isExpanded = false
            return
        }
        expandMiniMap()
        isExpanded = true
    }
    
    /// Defines animation of expanding the mini map
    private func expandMiniMap() {
        UIView.animate(withDuration: MiniMapConstants.openCloseTime,
                       delay: MiniMapConstants.delay,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            guard self != nil else { return }
            let originalViewWidth = self!.view.bounds.width / MiniMapConstants.sizePercentage
            let originalMapHeight = self!.view.bounds.height
            self!.view.frame = CGRect(x: MiniMapConstants.paddingRight,
                                      y: MiniMapConstants.paddingTop,
                                      width: originalViewWidth - MiniMapConstants.paddingRight * 2,
                                      height: originalMapHeight)
            }, completion: nil)
    }
    
    /// Defines animation of shrinking the mini map
    private func shrinkMiniMap() {
        UIView.animate(withDuration: MiniMapConstants.openCloseTime,
                       delay: MiniMapConstants.delay,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            guard self != nil else { return }
            self!.view.frame = CGRect(x: self!.view.bounds.width + MiniMapConstants.paddingRight * 2 - MiniMapConstants.paddingRight -  (self!.view.bounds.width + MiniMapConstants.paddingRight * 2) * MiniMapConstants.sizePercentage,
                                      y: MiniMapConstants.paddingTop,
                                      width: (self!.view.bounds.width + MiniMapConstants.paddingRight * 2) * MiniMapConstants.sizePercentage,
                                      height: self!.view.bounds.height)
            }, completion: nil)
    }
    
    /// Sets the route in the minimap
    func setRoute(with route: Route) {
        self.route = route
    }

}
