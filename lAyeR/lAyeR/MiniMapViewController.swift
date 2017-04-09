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
    
    var checkpointCardControllers: [CheckpointCardController] = [] {
        didSet {
            drawCheckpoint()
        }
    }
    
    var poiCardControllers: [PoiCardController] = [] {
        didSet {
            
        }
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
    }
    
    func drawCheckpoint() {
        mapViewS.clear()
        guard checkpointCardControllers.count > 0 else { return }
        for index in 0..<checkpointCardControllers.count - 1 {
            let fromCheckpoint = checkpointCardControllers[index].checkpoint
            let toCheckpoint = checkpointCardControllers[index + 1].checkpoint
            let from = CLLocationCoordinate2D(latitude: fromCheckpoint.latitude,
                                              longitude: fromCheckpoint.longitude)
            let to = CLLocationCoordinate2D(latitude: toCheckpoint.latitude,
                                            longitude: toCheckpoint.longitude)
            let path = GMSMutablePath()
            path.add(from)
            path.add(to)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.geodesic = true
            polyline.strokeColor = UIColor(red: 0.4549, green: 0.4078, blue: 0.3333, alpha: 1)
            polyline.map = mapViewS
        }
    }
    
    func toggleMiniMapSize() {
        if isExpanded {
            shrinkMiniMap()
            isExpanded = false
            return
        }
        expandMiniMap()
        isExpanded = true
    }
    
    private func expandMiniMap() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.frame = CGRect(x: miniMapPaddingRight, y: miniMapPaddingTop,
                                     width: self.view.bounds.width / miniMapSizePercentage - miniMapPaddingRight * 2,
                                     height: self.view.bounds.height)
        }, completion: nil)
    }
    
    private func shrinkMiniMap() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.frame = CGRect(x: self.view.bounds.width + miniMapPaddingRight * 2 - miniMapPaddingRight -  (self.view.bounds.width + miniMapPaddingRight * 2) * miniMapSizePercentage,
                                     y: miniMapPaddingTop,
                                     width: (self.view.bounds.width + miniMapPaddingRight * 2) * miniMapSizePercentage,
                                     height: self.view.bounds.height)
        }, completion: nil)
    }
    
}
