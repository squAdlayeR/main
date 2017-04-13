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
 controller to call out a mini map into the application view
 */
class MiniMapViewController: UIViewController, GMSMapViewDelegate {
    
    // The main map view
    var mapViewS: GMSMapView!
    
    // Defines geo manager for location queries
    var geoManager = GeoManager.getInstance()
    
    // See whether the mini map is open or not
    var isExpanded = false
    
    // Defines the checkpoints that will be shown on the minimap
    var route: Route = Route("route to be shown in minimap") {
        didSet { drawPath() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMap()
    }
    
    /// Initializes the mini map
    private func initializeMap() {
        let camera = GMSCameraPosition.camera(withLatitude: geoManager.getLastUpdatedUserPoint().latitude,
                                              longitude: geoManager.getLastUpdatedUserPoint().longitude,
                                              zoom: miniMapZoomLevel)
        mapViewS = GMSMapView.map(withFrame: view.bounds, camera: camera)
        stylizeGMap()
        changeGMapSettings()
        mapViewS.animate(to: camera)
        view.addSubview(mapViewS)
    }
    
    /// Change the styling of the google map, which includes:
    /// - the overall styling through json provided by google
    /// - alpha of the map
    private func stylizeGMap() {
        mapViewS.mapStyle = try? GMSMapStyle(jsonString: kMapStyle)
        mapViewS.alpha = miniMapAlpha
    }
    
    /// Change the overall map settings
    private func changeGMapSettings() {
        mapViewS.settings.myLocationButton = false
        mapViewS.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapViewS.isMyLocationEnabled = true
        mapViewS.delegate = self
        mapViewS.settings.setAllGesturesEnabled(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

/**
 An extension of mini map view controller that is used to interact with outer classes
 */
extension MiniMapViewController {
    
    /// Updates the current location to be displayed on the minimap
    /// - Parameter currentLocation: the current location of the user, represented by a geo point
    func updateMiniMap(with currentLocation: GeoPoint) {
        mapViewS.animate(to: GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                                     longitude: currentLocation.longitude,
                                                     zoom: miniMapZoomLevel))
    }
    
    /// Prepares the display of the view of the view contoller.
    /// - Parameter superView: the super view of the controller.
    func prepareMiniMapView(inside superView: UIView) {
        let mapViewFrame = CGRect(x: 0, y: 0,
                                  width: superView.bounds.width * miniMapSizePercentage,
                                  height: superView.bounds.width * miniMapSizePercentage)
        let center = CGPoint(x: superView.bounds.width - mapViewFrame.width / 2 - miniMapPaddingRight,
                             y: mapViewFrame.height / 2 + miniMapPaddingTop)
        view.frame = mapViewFrame
        view.center = center
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = miniMapBorderRadius
        view.layer.masksToBounds = true
        superView.addSubview(view)
        view.layer.zPosition = alertViewZPosition
    }
    
    /// Draws the path that is directing to the destination
    func drawPath() {
        mapViewS.clear()
        guard route.size > 0 else { return }
        let clUserPoint = getCLLocation(of: geoManager.getLastUpdatedUserPoint())
        createPath(from: clUserPoint, to: getCLLocation(of: route.checkPoints[0]))
        for index in 0 ..< route.size - 1 {
            let from = getCLLocation(of: route.checkPoints[index])
            let to = getCLLocation(of: route.checkPoints[index + 1])
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
        polyline.strokeWidth = miniMapStrokeWidth
        polyline.geodesic = true
        polyline.strokeColor = miniMapStrokeColor
        polyline.map = mapViewS
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
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard self != nil else { return }
            self!.view.frame = CGRect(x: miniMapPaddingRight, y: miniMapPaddingTop,
                                     width: self!.view.bounds.width / miniMapSizePercentage - miniMapPaddingRight * 2,
                                     height: self!.view.bounds.height)
        }, completion: nil)
    }
    
    /// Defines animation of shrinking the mini map
    private func shrinkMiniMap() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            guard self != nil else { return }
            self!.view.frame = CGRect(x: self!.view.bounds.width + miniMapPaddingRight * 2 - miniMapPaddingRight -  (self!.view.bounds.width + miniMapPaddingRight * 2) * miniMapSizePercentage,
                                     y: miniMapPaddingTop,
                                     width: (self!.view.bounds.width + miniMapPaddingRight * 2) * miniMapSizePercentage,
                                     height: self!.view.bounds.height)
        }, completion: nil)
    }
    
}
