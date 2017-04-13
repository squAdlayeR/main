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

    func withinThreshold(first: CGPoint, second: CGPoint) -> Bool {
        let dist = sqrt((first.x - second.x) * (first.x - second.x) + (first.y - second.y) * (first.y - second.y))
        return Double(dist) <= threshold
    }
    
    func distanceFromPointToLine(point p: CGPoint, fromLineSegmentBetween l1: CGPoint, and l2: CGPoint) -> Double {
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
    
    func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool, using markersList: inout [GMSMarker], show: Bool, markerName: String) {
        let marker = GMSMarker(position: coordinate)
        marker.title = markerName
        marker.userData = CheckPoint(coordinate.latitude, coordinate.longitude, marker.title!, "", isControlPoint)
        if isControlPoint && show {
            marker.map = mapView
        }
        markersList.insert(marker, at: idx)
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool, using markersList: inout [GMSMarker], show: Bool) {
        addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint, using: &markers, show: true, markerName: checkpointDefaultName)
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D, at idx: Int, isControlPoint: Bool) {
        addMarker(coordinate: coordinate, at: idx, isControlPoint: isControlPoint, using: &markers, show: true, markerName: checkpointDefaultName)
    }
    
    func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int, using linesList: inout [GMSPolyline], show: Bool) {
        let path = GMSMutablePath()
        path.add(from)
        path.add(to)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.geodesic = true
        polyline.strokeColor = lineColor
        if show {
            polyline.map = mapView
        }
        linesList.insert(polyline, at: idx)
    }
    
    func addLine(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, at idx: Int) {
        addLine(from: from, to: to, at: idx, using: &lines, show: true)
    }
    
    func makeMarkerControlPoint(at idx: Int) {
        if idx >= 0 && idx < markers.count {
            let checkpoint = markers[idx].userData as! CheckPoint
            checkpoint.isControlPoint = true
            markers[idx].userData = checkpoint
            markers[idx].map = mapView
        }
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

}
