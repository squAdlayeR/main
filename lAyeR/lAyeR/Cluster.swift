//
//  Cluster.swift
//  lAyeR
//
//  Created by Desperado on 18/06/2017.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class Cluster {
    let poiCardControllers: [PoiCardController]
    
    init(poiCardControllers: [PoiCardController]) {
        self.poiCardControllers = poiCardControllers
        setPoiCardControllersBelonging()
    }
    
    private func setPoiCardControllersBelonging() {
        for controller in poiCardControllers {
            controller.cluster = self
        }
    }
    
    
}
