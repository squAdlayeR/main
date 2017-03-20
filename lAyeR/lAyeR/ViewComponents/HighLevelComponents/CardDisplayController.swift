//
//  CardDisplayController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 20/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

protocol CardDisplayController {

    var superView: UIView! { get set }
    var markerCard: BasicMarker! { get set }
    var popupController: BasicAlertController! { get set }
    
    func adjustWhenOutOfView(_ isOutOfView: Bool)
    func applyAdjustment(_ adjustment: ARLayoutAdjustment)
    func update(_ distance: Double)
    
}
