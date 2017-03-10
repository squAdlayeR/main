//
//  TopBanner.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 3/9/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 A class that is used to hold the top banner of the `LayerAlert`.
 */
class TopBanner: UIView {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    var title: String = titlePlaceHolder {
        didSet {
            setTitleLable()
        }
    }
    
    private(set) var alert: LayerAlert!
    
    /// Initialization
    init(alert: LayerAlert, title: String?) {
        self.alert = alert
        let topBannerFrame = CGRect(x: 0, y: alert.frame.height - topBannerHeight,
                                    width: alert.frame.width,
                                    height: topBannerHeight)
        super.init(frame: topBannerFrame)
        initBackgroundImage()
        initTitle(with: title)
        alert.addSubview(self)
    }
    
    /// Initializes background image of the top banner
    private func initBackgroundImage() {
        let backgroundImage = ResourceManager.getImageView(by: topBannerImage)
        backgroundImage.frame = imageFrame
        self.addSubview(backgroundImage)
    }
    
    /// Initializes title label of the top banner
    private func initTitle(with title: String?) {
        if let title = title {
            self.title = title
            return
        }
        setTitleLable()
    }
    
    /// Set the title lable to the string that "title" specifies
    private func setTitleLable() {
        removeCurrentTitle()
        titleLabel = makeNewTitleLable()
        self.addSubview(titleLabel!)
    }
    
    /// Makes a new title lable according to the new title and config
    /// - Returns: a new title label
    private func makeNewTitleLable() -> UILabel {
        let newLable = UILabel()
        newLable.frame = titleFrame
        newLable.text = title
        newLable.font = UIFont(name: titleFontName, size: titleFontSize)
        newLable.textColor = titleFontColor
        newLable.textAlignment = NSTextAlignment.center
        newLable.alpha = 0
        return newLable
    }
    
    /// Removes the current title
    private func removeCurrentTitle() {
        guard let titleLable = titleLabel else { return }
        titleLable.removeFromSuperview()
        self.titleLabel = nil
    }
    
    /// Calculates a relatively suitable background image frame
    private var imageFrame: CGRect {
        return CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    /// Calculates a relatively suitable title label frame
    private var titleFrame: CGRect {
        return CGRect(x: 0,
                      y: self.frame.height * 0.15,
                      width: self.frame.width,
                      height: self.frame.height * 0.8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

/**
 An extension that is used to set top banner movement / visibility
 */
extension TopBanner {
    
    /// Opens the top banner
    func open() {
        self.transform = CGAffineTransform(translationX: 0,
                                           y: 0 - (self.alert.frame.height / 2 - self.frame.height))
    }
    
    /// Closes the top banner
    func close() {
        self.transform = CGAffineTransform(translationX: 0,
                                           y: self.alert.frame.height / 2 - self.frame.height)
    }
    
    /// Show title
    func showTitle() {
        self.titleLabel?.alpha = 1
    }
    
    /// Hide title
    func hideTitle() {
        self.titleLabel?.alpha = 0
    }
    
}
