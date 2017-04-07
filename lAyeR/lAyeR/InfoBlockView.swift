//
//  InfoBlockView.swift
//  lAyeR
//
//  Created by BillStark on 4/7/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class InfoBlockView: UIView {

//    var icon: UIImageView!
    var text: InfoBlock!
    var blurEffect: UIVisualEffectView!
    
    init(label: String, content: String, width: CGFloat) {
        let infoBlock = InfoBlock(label: label, content: content, width: width * 0.9 - 10)
        let initialFrame = CGRect(x: 0, y: 0, width: width, height: infoBlock.bounds.height + 15)
        super.init(frame: initialFrame)
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.layer.cornerRadius = 5
        blurEffectView.layer.masksToBounds = true
        self.blurEffect = blurEffectView
        self.addSubview(blurEffectView)

        text = infoBlock
        text.frame.origin = CGPoint(x: 10, y: 5)
        blurEffectView.addSubview(text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
