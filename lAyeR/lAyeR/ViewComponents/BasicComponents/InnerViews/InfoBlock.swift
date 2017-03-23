//
//  InfoBlock.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 23/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

class InfoBlock: UILabel {

    init(label: String, content: String, width: CGFloat) {
        let initialFrame = CGRect(x: 0, y: 0, width: width, height: 0)
        super.init(frame: initialFrame)
        prepareContent(label, content)
    }
    
    private func prepareContent(_ label: String, _ content: String) {
        let formatedInfo = formatingInfo(label, content)
        self.attributedText = formatedInfo
        self.textColor = UIColor.white
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.sizeToFit()
    }
    
    private func formatingInfo(_ label: String, _ conetent: String) -> NSMutableAttributedString {
        let formatedLabel = formatingLabel(label)
        let formatedContent = formatingContent("\n\(conetent)")
        formatedLabel.append(formatedContent)
        return formatedLabel
    }
    
    private func formatingLabel(_ labelText: String) -> NSMutableAttributedString {
        let label = NSMutableAttributedString(string: labelText,
            attributes: [NSFontAttributeName: UIFont(name: "HomenajeMod-Bold", size: 18)!])
        return label
    }
    
    private func formatingContent(_ contentText: String) -> NSAttributedString {
        let text = NSAttributedString(string: contentText,
            attributes: [NSFontAttributeName: UIFont(name: "HomenajeMod-Regular", size: 14)!])
        return text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
