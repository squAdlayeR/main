//
//  RouteListCell.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 31/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 This class is used to define a table view that will contain
 route infomation created by users.
 Basically, it contains:
 - route screen shot
 - route name
 - route description
 */
class RouteListCell: UITableViewCell {
    
    // Connects the name of the route
    @IBOutlet weak var routeName: UILabel!
    
    // Connects the description of the route
    @IBOutlet weak var routeDescription: UILabel!
    
    // Connects the background image
    @IBOutlet weak var backgroundImage: UIImageView!
    
    // Connects the check mark for selection
    @IBOutlet weak var checkMark: UIImageView!
    
    // Connects the overLay
    @IBOutlet weak var overLay: UIView!
    
    /// This will be called when the table cell is loaded.
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareImageOverlay()
        stylizeListCell()
    }
    
    /// Sets an overlay above the route screen shot so that the texts
    /// in the front can be seen
    private func prepareImageOverlay() {
        overLay.backgroundColor = MiscConstants.overlayBackgroundColor
        backgroundImage.layer.cornerRadius = MiscConstants.cornerRadius
        backgroundImage.layer.masksToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        overLay.layer.cornerRadius = MiscConstants.cornerRadius
        overLay.layer.masksToBounds = true
    }
    
    /// Defines styling of the list cell
    private func stylizeListCell() {
        selectionStyle = .none
    }
    
}
