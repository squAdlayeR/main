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
class LabelTextBlock: UILabel {

    /// Initialization
    /// - Parameters:
    ///     - label: the label of the info blcok
    ///     - content: the content of the info block
    ///     - width: the width of the info block
    init(label: String, icon: String, content: String, width: CGFloat) {
        let initialFrame = CGRect(x: 0, y: 0, width: width, height: 0)
        super.init(frame: initialFrame)
        prepareContent(label, icon, content)
    }
    
    /// Prepares the content of the info block. i.e. formating
    /// the information that will be displayed
    /// - Parameters:
    ///     - label: the label of the info block
    ///     - icon: the name of the icon image
    ///     - content: the content of the info blcok
    private func prepareContent(_ label: String, _ icon: String, _ content: String) {
        let formatedInfo = formatingInfo(label, icon, content)
        self.attributedText = formatedInfo
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.sizeToFit()
    }
    
    /// Formates the whole info text, including label and content
    /// - Parameters:
    ///     - label: the label of the info block
    ///     - icon: the name of the icon image
    ///     - conetent: the contentn of the info block
    /// - Returns: an attributed string that represents the info text
    private func formatingInfo(_ label: String, _ icon: String, _ conetent: String) -> NSMutableAttributedString {
        let formatedLabel = formatingLabel(label, icon)
        let formatedContent = formatingContent("\(InnerViewConstants.newLine)\(conetent)")
        formatedLabel.append(formatedContent)
        return formatedLabel
    }
    
    /// Formates the label of the info block
    /// - Parameters: 
    ///     - labelText: the label of the info block
    ///     - iconName: the name of the icon image
    /// - Returns: an attributed string the represents the label
    private func formatingLabel(_ labelText: String, _ iconName: String) -> NSMutableAttributedString {
        let label = NSMutableAttributedString(string: "\(InnerViewConstants.whiteSpace)\(labelText)",
            attributes: [NSFontAttributeName: UIFont(name: UIBasicConstants.defaultFontMedium, size: InnerViewConstants.labelFontSize)!,
                         NSForegroundColorAttributeName: UIColor.lightGray])
        let result = NSMutableAttributedString()
        let icon = createIconAttachment(iconName)
        result.append(icon)
        result.append(label)
        return result
    }
    
    /// Creates an attributed string that contains an icon
    /// - Parameter iconName: the name of the icon
    /// - Returns: an attributed string that contains the icon
    private func createIconAttachment(_ iconName: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: 0,
                                   width: InnerViewConstants.labelIconSize,
                                   height: InnerViewConstants.labelIconSize)
        attachment.image = UIImage(named: iconName)
        return NSAttributedString(attachment: attachment)
    }
    
    /// Formates the content of the info block
    /// - Parameter contentText: the content of the info block
    /// - Returns: an attributed string the represents the content
    private func formatingContent(_ contentText: String) -> NSAttributedString {
        let text = NSAttributedString(string: contentText,
            attributes: [NSFontAttributeName: UIFont(name: UIBasicConstants.defaultFontRegular, size: InnerViewConstants.contentFontSize)!,
                         NSForegroundColorAttributeName: UIColor.white])
        return text
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
