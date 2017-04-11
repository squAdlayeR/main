//
//  TrackPointNode.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/10/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation

class TrackPointNode: Comparable, Hashable {
    let trackPoint: TrackPointStruct
    let parent: TrackPointNode?
    let g: Double // cost
    let f: Double // heuristic
    init(trackPoint: TrackPointStruct, parent: TrackPointNode?, g: Double, f: Double) {
        self.trackPoint = trackPoint
        self.parent = parent
        self.g = g
        self.f = f
    }
    
    var hashValue: Int { return (Int) (g + f) }
}

func < (lhs: TrackPointNode, rhs: TrackPointNode) -> Bool {
    return (lhs.g + lhs.f) < (rhs.g + rhs.f)
}

func == (lhs: TrackPointNode, rhs: TrackPointNode) -> Bool {
    return lhs === rhs
}
