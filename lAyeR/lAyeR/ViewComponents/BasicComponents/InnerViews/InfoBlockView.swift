//
//  InfoBlockView.swift
//  lAyeR
//
//  Created by BillStark on 4/7/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 An view that is used to wrap and stylize an info block.
 */
class InfoBlockView: UIView {
    
    /// Initialization
    /// - Parameters:
    ///     - label: the label of the info block
    ///     - iconName: the name of the icon that is in the label
    ///     - content: the content of the info block
    ///     - width: the width of the info block view
    init(label: String, iconName: String, content: String, width: CGFloat) {
        let infoBlock = LabelTextBlock(label: label,
                                  icon: "\(iconName)\(MiscConstants.coloredIconExtension)",
                                  content: content,
                                  width: width - InnerViewConstants.infoBlockSidePadding * 2)
        let initialFrame = CGRect(x: 0, y: 0, width: width, height: infoBlock.bounds.height + InnerViewConstants.infoBlockPaddingTop * 3)
        super.init(frame: initialFrame)
        
        let blurEffectView = createBlurEffectView()
        self.addSubview(blurEffectView)

        infoBlock.frame.origin = CGPoint(x: InnerViewConstants.infoBlockSidePadding, y: InnerViewConstants.infoBlockPaddingTop)
        blurEffectView.addSubview(infoBlock)
    }
    
    /// Creates a blur effect that will be used as the background of the info block
    /// - Returns: a blur effect view
    private func createBlurEffectView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.layer.cornerRadius = InnerViewConstants.infoBlockCornerRadius
        blurEffectView.layer.masksToBounds = true
        return blurEffectView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
