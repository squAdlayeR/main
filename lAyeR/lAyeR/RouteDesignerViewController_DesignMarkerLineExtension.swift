//
//  RouteDesignerViewController_DesignMarkerLineExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/10/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps

extension RouteDesignerViewController {
    
    //---------- Navigating Data Structure
    
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
    
    //---------- Path
    
    func addPath(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if manualRouteType {
            addPoint(coordinate: coordinate, isControlPoint: isControlPoint, at: idx)
            addToHistory()
        } else {
            let lastPoint = markers.isEmpty ? source! : markers.last!.position
            getDirections(origin: "\(lastPoint.latitude) \(lastPoint.longitude)", destination: "\(coordinate.latitude) \(coordinate.longitude)", waypoints: nil, removeAllPoints: false, at: idx) { (result) -> () in
                if result {
                    self.addToHistory()
                }
            }
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    //---------- Point
    
    func addPoint(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int, usingMarkersList markersList: inout [GMSMarker], usingLinesList linesList: inout [GMSPolyline], show: Bool, markerName: String) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if idx >= markersList.count {
            var lastLocation = usingCurrentLocationAsSource ? myLocation!.coordinate : coordinate
            if !markersList.isEmpty {
                lastLocation = markersList.last!.position
            } else {
                mySource = coordinate
            }
            addLine(from: lastLocation, to: coordinate, at: markersList.count, using: &linesList, show: show)
            addMarker(coordinate: coordinate, at: markersList.count, isControlPoint: isControlPoint, using: &markersList, show: show, markerName: markerName)
        } else if idx >= 0 {
            removeLine(at: idx)
            addLine(from:  coordinate, to: markersList[idx].position, at: idx, using: &linesList, show: show)
            addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint, using: &markersList, show: show, markerName: markerName)
            let beforeCoord = idx == 0 ? usingCurrentLocationAsSource ? myLocation!.coordinate : coordinate : markersList[idx-1].position
            addLine(from: beforeCoord, to: coordinate, at: idx, using: &linesList, show: show)
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func addPoint(coordinate: CLLocationCoordinate2D, isControlPoint: Bool, at idx: Int) {
        addPoint(coordinate: coordinate, isControlPoint: isControlPoint, at: idx, usingMarkersList: &markers, usingLinesList: &lines, show: true, markerName: RouteDesignerConstants.checkpointDefaultName)
    }
    
    func removePoint(at idx: Int) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
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
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func removeAllPoints(usingMarkersList markersList: inout [GMSMarker], usingLinesList linesList: inout [GMSPolyline]) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        for marker in markersList {
            marker.map = nil
        }
        for line in linesList {
            line.map = nil
        }
        markersList.removeAll()
        linesList.removeAll()
        infoWindow.removeFromSuperview()
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func removeAllPoints() {
        removeAllPoints(usingMarkersList: &markers, usingLinesList: &lines)
    }
    
    //---------- Marker
    
    private func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool, using markersList: inout [GMSMarker], show: Bool, markerName: String) {
        let marker = GMSMarker(position: coordinate)
        marker.title = markerName
        marker.userData = CheckPoint(coordinate.latitude, coordinate.longitude, marker.title!, "", isControlPoint)
        if isControlPoint && show {
            marker.map = mapView
        }
        markersList.insert(marker, at: idx)
    }
    
    // Adds Marker with default name
    private func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool, using markersList: inout [GMSMarker], show: Bool) {
        addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint, using: &markers, show: true, markerName: RouteDesignerConstants.checkpointDefaultName)
    }
    
    // Adds Marker with default name and shows on map
    private func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool) {
        addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint, using: &markers, show: true, markerName: RouteDesignerConstants.checkpointDefaultName)
    }
    
    private func removeMarker(at idx: Int) {
        if idx >= 0 && idx < markers.count {
            markers[idx].map = nil
            markers.remove(at:idx)
        }
    }
    
    func makeMarkerControlPoint(at idx: Int) {
        if idx >= 0 && idx < markers.count {
            let checkpoint = markers[idx].userData as! CheckPoint
            checkpoint.isControlPoint = true
            markers[idx].userData = checkpoint
            markers[idx].map = mapView
        }
    }
    
    //---------- Line
    
    private func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int, using linesList: inout [GMSPolyline], show: Bool) {
        let path = GMSMutablePath()
        path.add(from)
        path.add(to)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = RouteDesignerConstants.lineStrokeWidth
        polyline.geodesic = true
        polyline.strokeColor = RouteDesignerConstants.mapLineColor
        if show {
            polyline.map = mapView
        }
        linesList.insert(polyline, at: idx)
    }
    
    private func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int) {
        addLine(from: from, to: to, at: idx, using: &lines, show: true)
    }
    
    private func removeLine(at idx: Int) {
        if idx >= 0 && idx < lines.count {
            lines[idx].map = nil
            lines.remove(at:idx)
        }
    }
    
    func modifyManualLine(at idx: Int) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if idx >= 0 && idx < lines.count {
            let from = idx == 0 ? source! : markers[idx-1].position
            let to = markers[idx].position
            removeLine(at: idx)
            addLine(from: from, to: to, at: idx)
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }
    
    func modifyToGoogleLine(at idx: Int) {
        if RouteDesignerConstants.testing { assert(checkRep()) }
        if idx >= 0 && idx < lines.count {
            let from = idx == 0 ? source! : markers[idx-1].position
            let to = markers[idx].position
            if !manualRouteType {
                getDirections(origin: "\(from.latitude) \(from.longitude)", destination: "\(to.latitude) \(to.longitude)", waypoints: nil, removeAllPoints: false, at: idx) { (result) -> () in
                    // print(result)
                }
            }
        }
        if RouteDesignerConstants.testing { assert(checkRep()) }
    }

}
