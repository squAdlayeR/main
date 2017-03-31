//
//  RouteListCell.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 31/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

class RouteListCell: UITableViewCell {
    
    
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var routeDescription: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let overlay = UIView(frame: backgroundImage.bounds)
        overlay.backgroundColor = UIColor(red: CGFloat(48/255), green: CGFloat(52/255), blue: CGFloat(65/255), alpha: 0.5)
        backgroundImage.layer.cornerRadius = 5
        backgroundImage.layer.masksToBounds = true
        backgroundImage.addSubview(overlay)
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
