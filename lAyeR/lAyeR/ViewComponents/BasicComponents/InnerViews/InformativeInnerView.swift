//
//  InformativeInnerView.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 22/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

class InformativeInnerView: UIView {
    
    private var scrollView: UIScrollView!
    private var innerViewStack: UIView!

    init(width: CGFloat, height: CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        initializeElements()
        initializeContent()
    }
    
    private func initializeElements() {
        scrollView = UIScrollView()
        innerViewStack = UIView()
    }
    
    private func initializeContent() {
        scrollView.frame = self.bounds.insetBy(dx: 20, dy: 0)
        innerViewStack.frame = CGRect(x: 0, y: 0,
                                      width: scrollView.bounds.width,
                                      height: scrollView.bounds.height)
        scrollView.contentSize = innerViewStack.bounds.size
        scrollView.addSubview(innerViewStack)
        self.addSubview(scrollView)
        let subtitle = createSubtitle()
        insertSubInfo(subtitle)
    }
    
    private func createSubtitle() -> UILabel {
        let label = UILabel()
        let frame = CGRect(x: 0, y: 0, width: self.bounds.width - 40, height: 20)
        label.frame = frame
        label.font = UIFont(name: "HomenajeMod-Regular", size: 14)
        label.textColor = UIColor.gray
        label.text = "Detailed infomation"
        label.textAlignment = NSTextAlignment.center
        return label
    }
    
    func insertSubInfo(_ view: UIView) {
        if let lastSubview = innerViewStack.subviews.last {
            view.frame.origin = CGPoint(x: 0, y: lastSubview.frame.origin.y + lastSubview.frame.height + 10)
        }
        innerViewStack.addSubview(view)
        updateFrame()
    }
    
    private func updateFrame() {
        guard var exactRect = self.innerViewStack.subviews.first?.frame else { return }
        for subView in innerViewStack.subviews {
            exactRect = exactRect.union(subView.frame)
        }
        innerViewStack.frame = CGRect(x: 0, y: 0, width: exactRect.width, height: exactRect.height)
        scrollView.contentSize = innerViewStack.bounds.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
