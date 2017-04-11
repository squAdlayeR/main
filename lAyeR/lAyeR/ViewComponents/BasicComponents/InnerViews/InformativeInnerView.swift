//
//  InformativeInnerView.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 22/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 A class that is used to define informative inner view. i.e.
 just for displaying information about certain checkpoint/poi
 */
class InformativeInnerView: UIView {
    
    // Defines the scrollable view
    private var scrollView: UIScrollView!
    
    // Defines the real inner view stack
    private var innerViewStack: UIView!
    
    private var hasSubTitle = true

    /// Initialization
    /// - Parameters:
    ///     - width: the bounded width of the inner view
    ///     - height: the bounded height of the inner view
    init(width: CGFloat, height: CGFloat, hasSubTitle: Bool) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        self.hasSubTitle = hasSubTitle
        initializeElements()
        initializeContent()
    }
    
    /// Initializes the main elements in the inner view.
    /// - Note: scroll view wraps the view stack so that it will
    ///     not exceed the defined height
    private func initializeElements() {
        scrollView = UIScrollView()
        innerViewStack = UIView()
    }
    
    /// Initializes the default content
    /// - Note: by default, there will be subtitle showing that this
    ///     inner view is used to define detailed infomation
    private func initializeContent() {
        scrollView.frame = self.bounds.insetBy(dx: innerViewSidePadding, dy: 0)
        innerViewStack.frame = CGRect(x: 0, y: 0,
                                      width: scrollView.bounds.width,
                                      height: scrollView.bounds.height)
        scrollView.contentSize = innerViewStack.bounds.size
        scrollView.addSubview(innerViewStack)
        self.addSubview(scrollView)
        if hasSubTitle {
            let subtitle = createSubtitle()
            insertSubInfo(subtitle)
        }
    }
    
    /// Creates a subtitle for the inner view.
    /// - Returns: the designed subtitle
    private func createSubtitle() -> UILabel {
        let label = UILabel()
        let frame = CGRect(x: 0, y: innerViewStackMargin,
                           width: self.bounds.width - innerViewSidePadding * 2,
                           height: infoPanelTitleHeight)
        label.frame = frame
        label.font = UIFont(name: alterDefaultFontRegular, size: defaultFontSize)
        label.textColor = infoPanelTitleFontColor
        label.text = titleText
        label.textAlignment = NSTextAlignment.center
        return label
    }
    
    /// Inserts a sub info block into the inner view stack
    /// - Parameter view: the view that will be inserted into the view stack
    func insertSubInfo(_ view: UIView) {
        if let lastSubview = innerViewStack.subviews.last {
            print(view.frame)
            view.frame.origin = CGPoint(x: 0,
                                        y: lastSubview.frame.origin.y
                                            + lastSubview.frame.height
                                            + innerViewStackMargin)
            view.frame.size = CGSize(width: view.bounds.width,
                                     height: view.bounds.height + innerViewStackMargin)
            print(view.frame.size)
        }
        innerViewStack.addSubview(view)
        updateFrame()
    }
    
    /// Updates the scroll view content size after inserting a new view element
    private func updateFrame() {
        guard var exactRect = self.innerViewStack.subviews.first?.frame else { return }
        for subView in innerViewStack.subviews {
            exactRect = exactRect.union(subView.frame)
        }
        innerViewStack.frame = CGRect(x: 0, y: 0, width: exactRect.width, height: exactRect.height)
        scrollView.contentSize = innerViewStack.bounds.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
