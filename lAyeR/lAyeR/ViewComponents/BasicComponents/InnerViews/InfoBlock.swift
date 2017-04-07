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
    init(label: String, content: String, width: CGFloat) {
        let initialFrame = CGRect(x: 0, y: 0, width: width, height: 0)
        super.init(frame: initialFrame)
        prepareContent(label, content)
    }
    
    /// Prepares the content of the info block. i.e. formating
    /// the information that will be displayed
    /// - Parameters:
    ///     - label: the label of the info block
    ///     - content: the content of the info blcok
    private func prepareContent(_ label: String, _ content: String) {
        let formatedInfo = formatingInfo(label, content)
        self.attributedText = formatedInfo
//        self.textColor = defaultFontColor
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.sizeToFit()
    }
    
    /// Formates the whole info text, including label and content
    /// - Parameters:
    ///     - label: the label of the info block
    ///     - conetent: the contentn of the info block
    /// - Returns: an attributed string that represents the info text
    private func formatingInfo(_ label: String, _ conetent: String) -> NSMutableAttributedString {
        let formatedLabel = formatingLabel(label)
        let formatedContent = formatingContent("\n\(conetent)")
        formatedLabel.append(formatedContent)
        return formatedLabel
    }
    
    /// Formates the label of the info block
    /// - Parameter labelText: the label of the info block
    /// - Returns: an attributed string the represents the label
    private func formatingLabel(_ labelText: String) -> NSMutableAttributedString {
        let labelColor = UIColor(red: CGFloat(1.0 / 255),
                                 green: CGFloat(159.0 / 255),
                                 blue: CGFloat(232.0 / 255), alpha: 1)
        let label = NSMutableAttributedString(string: labelText,
            attributes: [NSFontAttributeName: UIFont(name: alterDefaultFontMedium, size: labelFontSize)!,
                         NSForegroundColorAttributeName: labelColor])
        return label
    }
    
    /// Formates the content of the info block
    /// - Parameter contentText: the content of the info block
    /// - Returns: an attributed string the represents the content
    private func formatingContent(_ contentText: String) -> NSAttributedString {
        let textColor = UIColor(red: CGFloat(233.0 / 255),
                                green: CGFloat(232.0 / 255),
                                blue: CGFloat(231.0 / 255), alpha: 1)
        let text = NSAttributedString(string: contentText,
            attributes: [NSFontAttributeName: UIFont(name: alterDefaultFontRegular, size: defaultFontSize)!,
                         NSForegroundColorAttributeName: textColor])
        return text
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
