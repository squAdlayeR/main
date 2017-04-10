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
        setImageOverlay()
    }
    
    /// Sets an overlay above the route screen shot so that the texts
    /// in the front can be seen
    func setImageOverlay() {
        overLay.backgroundColor = UIColor(red: CGFloat(48 / 255),
                                          green: CGFloat(52 / 255),
                                          blue: CGFloat(65 / 255),
                                          alpha: 0.5)
        backgroundImage.layer.cornerRadius = 5
        backgroundImage.layer.masksToBounds = true
        backgroundImage.contentMode = .scaleAspectFill
        overLay.layer.cornerRadius = 5
        overLay.layer.masksToBounds = true
    }

}
