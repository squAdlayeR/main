//
//  LayerAlert.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class LayerAlert: UIView {
    
    var topBanner: TopBanner!
    var bottomBanner: BottomBanner!
    var infoPanel: InfoPanel!
    var isOpened = false
    
    init(frame: CGRect, topBannerHeight: CGFloat, bottomBannerHeight: CGFloat) {
        super.init(frame: frame)
        initBanners(with: topBannerHeight, and: bottomBannerHeight)
        self.transform = CGAffineTransform(scaleX: 0.1, y: 1)
        self.alpha = 0
    }
    
    private func initBanners(with topBannerHeight: CGFloat, and bottomBannerHeight: CGFloat) {
        initTopBanner(with: topBannerHeight)
        initBottomBanner(with: bottomBannerHeight)
        initInfoPanel(with: topBannerHeight, and: bottomBannerHeight)
    }
    
    private func initTopBanner(with height: CGFloat) {
        let newTopBanner = TopBanner()
        let frame = CGRect(x: 0,
                           y: self.frame.height / 2 - height,
                           width: self.frame.width,
                           height: height)
        newTopBanner.frame = frame
        topBanner = newTopBanner
        let imageFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
        let backgroundImage = getImageView(by: "bannerTop.png")
        backgroundImage.frame = imageFrame
        topBanner.addSubview(backgroundImage)
        self.addSubview(topBanner)
    }
    
    private func initBottomBanner(with height: CGFloat) {
        let newBottomBanner = BottomBanner()
        let frame = CGRect(x: 0,
                           y: self.frame.height / 2,
                           width: self.frame.width,
                           height: height)
        newBottomBanner.frame = frame
        bottomBanner = newBottomBanner
        let imageFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
        let backgroundImage = getImageView(by: "bannerBottom.png")
        backgroundImage.frame = imageFrame
        bottomBanner.addSubview(backgroundImage)
        self.addSubview(bottomBanner)
    }
    
    private func initInfoPanel(with topBannerHeight: CGFloat, and bottomBannerHeight: CGFloat) {
        let newInfoPanel = InfoPanel()
        let frame = CGRect(x: 0.5,
                           y: 0 + topBannerHeight,
                           width: self.frame.width,
                           height: self.frame.height - topBannerHeight - bottomBannerHeight)
        newInfoPanel.frame = frame
        infoPanel = newInfoPanel
        let imageFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: infoPanel.frame.height)
        let backgroundImage = getImageView(by: "panelInfo.png")
        backgroundImage.frame = imageFrame
        infoPanel.addSubview(backgroundImage)
        infoPanel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
        self.addSubview(infoPanel)
    }
    
    private func getImageView(by name: String) -> UIImageView {
        let image = UIImage(named: name)
        let imageView = UIImageView(image: image)
        return imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension LayerAlert {
    
    func toggle() {
        if !isOpened {
            scaleWidthToNormal()
        } else {
            scaleWidthToInitial()
        }
        isOpened = !isOpened
    }
    
    func scaleWidthToNormal() {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alpha = 1
        }, completion: { isFinished in
            self.toggleBanners()
        })
    }
    
    func toggleBanners() {
        UIView.animate(withDuration: 0.2, animations: {
            self.topBanner.transform = CGAffineTransform(translationX: 0, y: 0 - self.topBanner.frame.origin.y)
            self.bottomBanner.transform = CGAffineTransform(translationX: 0, y: self.frame.height - (self.bottomBanner.frame.origin.y + self.bottomBanner.frame.height))
            self.infoPanel.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }

    
    func scaleWidthToInitial()  {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 1)
            self.alpha = 0
        }, completion: { isFinished in
            self.toggleBanners()
            self.closeInfoPanel()
        })
    }
    
    func closeInfoPanel() {
        infoPanel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
    }
    
}
