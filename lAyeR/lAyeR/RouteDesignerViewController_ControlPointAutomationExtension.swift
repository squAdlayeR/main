//
//  RouteDesignerViewController_ControlPointAutomationExtension.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/11/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation

extension RouteDesignerViewController {
    
    private struct vec {
        var x: Double
        var y: Double
        init(_ x: Double, _ y: Double) {
            self.x = x
            self.y = y
        }
    }
    
    private func toVec(_ a: CheckPoint, _ b: CheckPoint) -> vec {
        return vec(b.latitude - a.latitude, b.longitude - a.longitude)
    }
    
    private func cross(_ a: vec, _ b: vec) -> Double {
        return a.x * b.y - a.y * b.x
    }
    
    private func dot(_ a: vec, _ b: vec) -> Double {
        return a.x * b.x + a.y * b.y
    }
    
    private func norm_sq(_ v: vec) -> Double {
        return v.x * v.x + v.y * v.y
    }
    
    private func angle(from a: CheckPoint, through o: CheckPoint, to b: CheckPoint) -> Double {
        let oa = toVec(o,a)
        let ob = toVec(o,b)
        return acos(dot(oa, ob) / sqrt(norm_sq(oa) * norm_sq(ob)))
    }
    
    private func euclideanDistance(from source: CheckPoint, to dest: CheckPoint) -> Double {
        let dist = sqrt((source.latitude - dest.latitude) * (source.latitude - dest.latitude) + (source.longitude - dest.longitude) * (source.longitude - dest.longitude))
        return dist
    }

    func addControlPointsToMarkers() {
        var totalDist = 0.0
        for idx in 2..<markers.count {
            let A = markers[idx-2].userData as! CheckPoint
            let O = markers[idx-1].userData as! CheckPoint
            let B = markers[idx].userData as! CheckPoint
            let turnAngle = angle(from: A, through: O, to: B)
            let nextDist = euclideanDistance(from: A, to: O)
            totalDist += nextDist
            if turnAngle < turnAngleThreshold {
                makeMarkerControlPoint(at: idx-1)
                totalDist = 0.0
            } else if totalDist > distanceThreshold {
                makeMarkerControlPoint(at: idx-1)
                totalDist = 0.0
            }
        }
    }
    
}
