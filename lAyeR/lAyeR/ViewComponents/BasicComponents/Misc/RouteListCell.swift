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
    
    /// This will be called when the table cell is loaded.
    override func awakeFromNib() {
        super.awakeFromNib()
        setImageOverlay()
        disableSelectionStyling()
    }
    
    /// Sets an overlay above the route screen shot so that the texts
    /// in the front can be seen
    private func setImageOverlay() {
        let overlay = UIView(frame: backgroundImage.bounds)
        overlay.backgroundColor = UIColor(red: CGFloat(48 / 255),
                                          green: CGFloat(52 / 255),
                                          blue: CGFloat(65 / 255),
                                          alpha: 0.5)
        backgroundImage.layer.cornerRadius = 5
        backgroundImage.layer.masksToBounds = true
        backgroundImage.addSubview(overlay)
    }
    
    /// Disables the selection styling
    private func disableSelectionStyling() {
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
