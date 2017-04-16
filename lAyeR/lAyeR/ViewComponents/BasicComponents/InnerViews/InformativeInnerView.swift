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
    
    // stores the subtitle which will be displayed in as the first
    // line in the view
    private var subtitle: String!

    /// Initialization
    /// - Parameters:
    ///     - width: the bounded width of the inner view
    ///     - height: the bounded height of the inner view
    ///     - subtitle: the subtitle of the inner view
    init(width: CGFloat, height: CGFloat, subtitle: String) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        self.subtitle = subtitle
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
        scrollView.frame = self.bounds.insetBy(dx: InnerViewConstants.innerViewSidePadding, dy: 0)
        innerViewStack.frame = CGRect(x: 0, y: 0,
                                      width: scrollView.bounds.width,
                                      height: scrollView.bounds.height)
        scrollView.contentSize = innerViewStack.bounds.size
        scrollView.addSubview(innerViewStack)
        self.addSubview(scrollView)
        let subtitle = createSubtitle(with: self.subtitle)
        insertSubInfo(subtitle)
    }
    
    /// Creates a subtitle for the inner view.
    /// - Parameter subtitle: the subtitle of the inner view
    /// - Returns: the designed subtitle
    private func createSubtitle(with subtitle: String) -> UILabel {
        let label = UILabel()
        let frame = CGRect(x: 0, y: InnerViewConstants.innerViewStackMargin,
                           width: self.bounds.width - InnerViewConstants.infoBlockSidePadding * 2,
                           height: InnerViewConstants.innerViewTitleHeight)
        label.frame = frame
        label.font = UIFont(name: UIBasicConstants.defaultFontRegular, size: InnerViewConstants.innerViewTitleFontSize)
        label.textColor = UIColor.gray
        label.text = subtitle
        label.textAlignment = NSTextAlignment.center
        return label
    }
    
    /// Inserts a sub info block into the inner view stack
    /// - Parameter view: the view that will be inserted into the view stack
    func insertSubInfo(_ view: UIView) {
        insertView(view)
        updateFrame()
    }
    
    /// Purely inserts a view into the view stack
    /// - Parameter view: the view that is to be inserted into the inner view
    private func insertView(_ view: UIView) {
        if let lastSubview = innerViewStack.subviews.last {
            view.frame.origin = CGPoint(x: 0,
                                        y: lastSubview.frame.origin.y
                                            + lastSubview.frame.height
                                            + InnerViewConstants.innerViewStackMargin)
            view.frame.size = CGSize(width: view.bounds.width,
                                     height: view.bounds.height + InnerViewConstants.innerViewStackMargin)
        }
        innerViewStack.addSubview(view)
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
