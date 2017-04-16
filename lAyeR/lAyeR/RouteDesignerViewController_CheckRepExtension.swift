//
//  RouteDesignerViewController_CheckRepExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/16/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit
import GoogleMaps

extension RouteDesignerViewController {

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

}
