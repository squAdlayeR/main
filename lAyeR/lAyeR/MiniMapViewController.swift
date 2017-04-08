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
    var mapView: GMSMapView!
    
    // Defines geo manager for location queries
    var geoManager = GeoManager.getInstance()
    
    // See whether the mini map is open or not
    var isOpened = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMap()
    }
    
    /// Initializes the mini map
    private func initializeMap() {
        let camera = GMSCameraPosition.camera(withLatitude: geoManager.getLastUpdatedUserPoint().latitude,
                                              longitude: geoManager.getLastUpdatedUserPoint().longitude,
                                              zoom: miniMapZoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        stylizeGMap()
        changeGMapSettings()
        mapView.animate(to: camera)
        view.addSubview(mapView)
    }
    
    /// Change the styling of the google map, which includes:
    /// - the overall styling through json provided by google
    /// - alpha of the map
    private func stylizeGMap() {
        mapView.mapStyle = try? GMSMapStyle(jsonString: kMapStyle)
        mapView.alpha = miniMapAlpha
    }
    
    /// Change the overall map settings
    private func changeGMapSettings() {
        mapView.settings.myLocationButton = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.settings.setAllGesturesEnabled(false)
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
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                                     longitude: currentLocation.longitude,
                                                     zoom: miniMapZoomLevel))
    }
    
    /// Prepares the display of the view of the view contoller.
    /// - Parameter superView: the super view of the controller.
    func prepareMiniMapView(inside superView: UIView) {
        let mapViewFrame = CGRect(x: 0, y: 0,
                                  width: superView.bounds.width * miniMapSizePercentage,
                                  height: superView.bounds.width * miniMapSizePercentage)
        let center = CGPoint(x: superView.bounds.width - miniMapPaddingRight - mapViewFrame.width / 2,
                             y: mapViewFrame.width / 2 + miniMapPaddingTop)
        view.frame = mapViewFrame
        view.center = center
        mapView.layer.cornerRadius = miniMapBorderRadius
        mapView.layer.masksToBounds = true
        superView.addSubview(view)
        view.transform = CGAffineTransform(translationX: view.bounds.height + miniMapPaddingRight, y: 0)
    }
    
    /// Toggles the mini map
    func toggleMiniMap() {
        if isOpened {
            hideMiniMap()
            isOpened = false
            return
        }
        showMiniMap()
        isOpened = true
    }
    
    /// Shows the mini map with animation
    private func showMiniMap() {
        hideMiniMap()
        UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    /// Hides the mini map with animation
    private func hideMiniMap() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = CGAffineTransform(translationX: self.view.bounds.height + miniMapPaddingRight, y: 0)
        })
    }
    
}
