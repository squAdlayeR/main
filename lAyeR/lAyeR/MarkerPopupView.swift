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
    var addAfterButton: UIButton!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        topView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 100))
        topView.backgroundColor = UIColor.white
        topView.alpha = 0.7
        self.addSubview(topView)
        
        arrow = TriangleView(frame: CGRect(x: self.frame.size.width/2-8, y: 100, width: 16, height: 10))
        arrow.backgroundColor = UIColor.white
        arrow.alpha = 0.7
        self.addSubview(arrow)
        
        label = UILabel(frame: CGRect(x: 0, y: 12, width: self.frame.size.width, height: 30))
        label.text = "Checkpoint"
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        topView.addSubview(label)
        
        addAfterButton = UIButton(frame: CGRect(x: 0, y: 42, width: self.frame.size.width, height: 25))
        addAfterButton.setTitle("Add After", for: UIControlState.normal)
        addAfterButton.setTitleColor(UIColor.green, for: UIControlState.normal)
        addAfterButton.titleLabel?.textAlignment = NSTextAlignment.center
        topView.addSubview(addAfterButton)
        
        deleteButton = UIButton(frame: CGRect(x: 0, y: 67, width: self.frame.size.width, height: 25))
        deleteButton.setTitle("Delete", for: UIControlState.normal)
        deleteButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        deleteButton.titleLabel?.textAlignment = NSTextAlignment.center
        topView.addSubview(deleteButton)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
