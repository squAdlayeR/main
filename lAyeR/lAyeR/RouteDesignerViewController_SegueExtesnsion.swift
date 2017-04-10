//
//  RouteDesignerViewController_SegueExtesnsion.swift
//  lAyeR
//
//  Created by luoyuyang on 10/04/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation


extension RouteDesignerViewController {
    // ---------------- back segue to AR view --------------------//
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let arViewController = segue.destination as? ARViewController {
            arViewController.checkpointCardControllers.removeAll()
            for marker in markers {
                guard let checkpoint = marker.userData as? CheckPoint else {
                    break
                }
                let checkpointCard = CheckpointCard(center: CGPoint(x: -100, y: -100),  // for demo only, hide out of screen
                    distance: 0, superViewController: arViewController)
                checkpointCard.setCheckpointName(checkpoint.name)
                checkpointCard.setCheckpointDescription("Oops! This checkpoint has no specific description.")
                arViewController.checkpointCardControllers.append(CheckpointCardController(checkpoint: checkpoint,
                                                                                           card: checkpointCard))
            }
            if (!markers.isEmpty) {
                arViewController.checkpointCardControllers[0].setSelected(true)
            }
            arViewController.prepareNodes()
            //TODO: force update the POI in ARView
        }
    }
}
