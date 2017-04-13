//
//  MarkerPopup.swift
//  lAyeR
//
//  Created by Patrick Cho on 3/12/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//
import UIKit

class MarkerPopupView: UIView {
    
    var topView: UIView!
    var arrow: TriangleView!
    var label: UILabel!
    var deleteButton: UIButton!
    var editButton: UIButton!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        topView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 100))
        topView.backgroundColor = UIColor.black
        topView.layer.cornerRadius = 15
        topView.layer.masksToBounds = true
        topView.alpha = 0.8
        self.addSubview(topView)
        
        arrow = TriangleView(frame: CGRect(x: self.frame.size.width/2-8, y: 100, width: 16, height: 10))
        arrow.backgroundColor = UIColor.black
        arrow.alpha = 0.7
        self.addSubview(arrow)
        
        label = UILabel(frame: CGRect(x: 0, y: 12, width: self.frame.size.width, height: 30))
        label.text = "Checkpoint"
        label.textColor = UIColor.white
        label.font = UIFont(name: alterDefaultFontMedium, size: buttonFontSize)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        topView.addSubview(label)
        
        editButton = UIButton(frame: CGRect(x: 0, y: 42, width: self.frame.size.width, height: 25))
        editButton.setTitle("Insert Info", for: UIControlState.normal)
        editButton.setTitleColor(UIColor(red: CGFloat(38.0 / 255),
                                         green: CGFloat(194.0 / 255),
                                         blue: CGFloat(129.0 / 255),
                                         alpha: 1.0), for: UIControlState.normal)
        editButton.titleLabel?.textAlignment = NSTextAlignment.center
        editButton.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: 15)
        topView.addSubview(editButton)
        
        deleteButton = UIButton(frame: CGRect(x: 0, y: 67, width: self.frame.size.width, height: 25))
        deleteButton.setTitle("Delete Point", for: UIControlState.normal)
        deleteButton.setTitleColor(UIColor(red: CGFloat(192.0 / 255),
                                           green: CGFloat(57.0 / 255),
                                           blue: CGFloat(43.0 / 255),
                                           alpha: 1.0), for: UIControlState.normal)
        deleteButton.titleLabel?.textAlignment = NSTextAlignment.center
        deleteButton.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: 15)
        topView.addSubview(deleteButton)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
}
