//
//  TopBanner.swift
//  lAyeR
//
//  Created by BillStark on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class TopBanner: UIView {

    @IBOutlet weak var title: UILabel? {
        
        didSet {
            title!.frame = titleFrame
            title!.font = UIFont(name: "HomenajeMod-Bold", size: 30)
            title!.textAlignment = NSTextAlignment.center
            title!.textColor = UIColor.white
            self.addSubview(title!)
        }
        
    }
    
    var titleFrame: CGRect {
        return CGRect(x: 0,
                      y: self.frame.height * 0.15,
                      width: self.frame.width,
                      height: self.frame.height * 0.8)
    }

}
