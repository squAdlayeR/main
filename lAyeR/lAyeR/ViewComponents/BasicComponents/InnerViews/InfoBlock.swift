//
//  InfoBlock.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 23/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 This class defines a basic info block that will be used in lAyeR.
 This info block has the following attributes:
 - contains a label and text
 - unlimited length of content
 */
class InfoBlock: UILabel {

    /// Initialization
    /// - Parameters:
    ///     - label: the label of the info blcok
    ///     - content: the content of the info block
    ///     - width: the width of the info block
    init(label: String, imageName: String, content: String, width: CGFloat) {
        let initialFrame = CGRect(x: 0, y: 0, width: width, height: 0)
        super.init(frame: initialFrame)
//        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
        prepareContent(label, content, imageName)
    }
    
    /// Prepares the content of the info block. i.e. formating
    /// the information that will be displayed
    /// - Parameters:
    ///     - label: the label of the info block
    ///     - content: the content of the info blcok
    private func prepareContent(_ label: String, _ content: String, _ imageName: String) {
        let formatedInfo = formatingInfo(label, content, imageName)
        self.attributedText = formatedInfo
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.sizeToFit()
    }
    
    /// Formates the whole info text, including label and content
    /// - Parameters:
    ///     - label: the label of the info block
    ///     - conetent: the contentn of the info block
    ///     - imageName: the name of the icon image
    /// - Returns: an attributed string that represents the info text
    private func formatingInfo(_ label: String, _ conetent: String, _ imageName: String) -> NSMutableAttributedString {
        let formatedLabel = formatingLabel(label, imageName)
        let formatedContent = formatingContent("\n\(conetent)")
        formatedLabel.append(formatedContent)
        return formatedLabel
    }
    
    /// Formates the label of the info block
    /// - Parameters: 
    ///     - labelText: the label of the info block
    ///     - imageName: the name of the icon image
    /// - Returns: an attributed string the represents the label
    private func formatingLabel(_ labelText: String, _ imageName: String) -> NSMutableAttributedString {
//        let labelColor = UIColor(red: CGFloat(1.0 / 255),
//                                 green: CGFloat(159.0 / 255),
//                                 blue: CGFloat(232.0 / 255), alpha: 1)
        let labelColor = UIColor.lightGray
        let label = NSMutableAttributedString(string: "  " + labelText,
            attributes: [NSFontAttributeName: UIFont(name: alterDefaultFontMedium, size: labelFontSize)!,
                         NSForegroundColorAttributeName: labelColor])
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
        attachment.image = UIImage(named: imageName)
        let icon = NSAttributedString(attachment: attachment)
        let result = NSMutableAttributedString()
        result.append(icon)
        result.append(label)
        return result
    }
    
    /// Formates the content of the info block
    /// - Parameter contentText: the content of the info block
    /// - Returns: an attributed string the represents the content
    private func formatingContent(_ contentText: String) -> NSAttributedString {
//        let textColor = UIColor(red: CGFloat(233.0 / 255),
//                                green: CGFloat(232.0 / 255),
//                                blue: CGFloat(231.0 / 255), alpha: 1)
        let textColor = UIColor.white
        let text = NSAttributedString(string: contentText,
            attributes: [NSFontAttributeName: UIFont(name: alterDefaultFontRegular, size: defaultFontSize)!,
                         NSForegroundColorAttributeName: textColor])
        return text
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
