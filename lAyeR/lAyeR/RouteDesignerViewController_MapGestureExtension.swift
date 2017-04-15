//
//  RouteDesignerViewController_MapGestureExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/8/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

extension RouteDesignerViewController: GMSMapViewDelegate {
    
    //empty the default infowindow
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // reset custom infowindow whenever marker is tapped
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        let location = CLLocationCoordinate2D(latitude: (marker.userData as! CheckPoint).latitude, longitude: (marker.userData as! CheckPoint).longitude)
        
        tappedMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = MarkerPopupView(frame: CGRect(x: 0, y: 0, width: 150, height: 110))
        infoWindow.label.text = (marker.userData as! CheckPoint).name
        var centerPoint = mapView.projection.point(for: location)
        centerPoint.y = centerPoint.y - 95
        infoWindow.center = centerPoint
        infoWindow.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(gestureRecognizer:)), for: .touchUpInside)
        infoWindow.editButton.addTarget(self, action: #selector(editButtonTapped(gestureRecognizer:)), for: .touchUpInside)
        if RouteDesignerConstants.testing { assert(checkRep()) }
        return false
    }
    
    func deleteButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if myLocation == nil {
            return
        }
        infoWindow.removeFromSuperview()
        let tappedMarkerData = tappedMarker.userData as! CheckPoint
        let idx = findIdxInMarkers(of: tappedMarkerData)
        let prevIdx = findPreviousControlPoint(at: idx)
        let nextIdx = findNextControlPoint(at: idx)
        for _ in prevIdx+1..<nextIdx {
            removePoint(at: prevIdx+1)
        }
        modifyLine(at: prevIdx+1)
        historyOfMarkers.append(markers)
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func editButtonTapped(gestureRecognizer: UITapGestureRecognizer) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        let alert = UIAlertController(title: "Edit CheckPoint", message: "Enter Name and Description of CheckPoint", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter CheckPoint Name"
            let markerCheckpoint = self.tappedMarker.userData as! CheckPoint
            textField.text = markerCheckpoint.name
        }
        alert.addTextField { (textField) in
            let markerCheckpoint = self.tappedMarker.userData as! CheckPoint
            textField.text = markerCheckpoint.description
            textField.placeholder = "Enter CheckPoint Description"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let nameTextField = alert!.textFields![0]
            let descriptionTextField = alert!.textFields![1]
            if (nameTextField.text != nil && nameTextField.text != "" && descriptionTextField.text != nil) {
                let markerData = self.tappedMarker.userData as! CheckPoint
                let newMarkerData = CheckPoint(markerData.latitude, markerData.longitude, nameTextField.text!, descriptionTextField.text!, markerData.isControlPoint)
                self.tappedMarker.userData = newMarkerData
                
                let resultAlert = UIAlertController(title: "CheckPoint Details Saved Successfully", message: "Congrats", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            } else {
                let resultAlert = UIAlertController(title: "Save Failed", message: "Please give a name to this CheckPoint", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        infoWindow.removeFromSuperview()
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if (tappedMarker.userData != nil){
            let location = CLLocationCoordinate2D(latitude: (tappedMarker.userData as! CheckPoint).latitude, longitude: (tappedMarker.userData as! CheckPoint).longitude)
            var centerPoint = mapView.projection.point(for: location)
            centerPoint.y = centerPoint.y - 95
            infoWindow.center = centerPoint
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        infoWindow.removeFromSuperview()
        if selectingLayerRoute {
            selectRoute(coordinate: coordinate, forType: 0)
            if selectedRoute {
                focusOnOneRoute()
            }
        } else if selectingGpsRoute {
            selectRoute(coordinate: coordinate, forType: 1)
            if selectedRoute {
                focusOnOneRoute()
            }
        } else {
            addPath(coordinate: coordinate, isControlPoint: true, at: markers.count)
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        infoWindow.removeFromSuperview()
        if selectingSourceCoordinate {
            sourceBar.text = "\(coordinate.latitude) \(coordinate.longitude)"
            selectingSourceCoordinate = false
            sourcePin.alpha = 0.5
            useSourceCoordinates = true
        } else if selectingSearchCoordinate {
            searchBar.text = "\(coordinate.latitude) \(coordinate.longitude)"
            selectingSearchCoordinate = false
            searchPin.alpha = 0.5
            useDestCoordinates = true
        }
        if selectingLayerRoute {
            selectRoute(coordinate: coordinate, forType: 0)
        } else if selectingGpsRoute {
            selectRoute(coordinate: coordinate, forType: 1)
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
}
