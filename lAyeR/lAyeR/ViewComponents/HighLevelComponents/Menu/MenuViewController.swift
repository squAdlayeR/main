//
//  MenuViewController.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 26/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 A view controller that is used to control the popup menu.
 - Note: to used this controller, you need to define the open/close
    gesture by yourself.
 This controller supports the following functionalities:
 - opens a defined menu
 - closes a defined menu
 - add single button/button group to the menu
 */
class MenuViewController: NSObject {

    // Defines the view of the menu
    private(set) var menuView: MenuView!
    
    // checks whether the menu is opened currently
    var isOpened: Bool!
    
    /// Initializes the menu. The following will be done:
    /// - creates an empty menu view
    /// - hide the menu view
    /// - set is open to false
    override init() {
        super.init()
        self.menuView = MenuView()
        menuView.isHidden = true
        isOpened = false
    }
    
}

/**
 An extension that is used to define interaction functions
 of the menu
 */
extension MenuViewController {
    
    /// Adds a button to the menu. The button could be any UIView.
    /// - Parameter button: the button that will be added in
    func addMenuButton(_ button: UIView) {
        menuView.addButtons([button])
    }
    
    /// Adds a group of buttons into the menu.
    /// - Parameter buttons: an array of buttons that will be added
    ///     into the menu
    func addMenuButtons(_ buttons: [UIView]) {
        menuView.addButtons(buttons)
    }
    
    /// Presents the menu view inside a specified super view
    /// - Parameter superView: the super view that this menu
    ///     will be presented in
    func present(inside superView: UIView) {
        guard !isOpened else { return }
        menuView.isHidden = false
        
        updateMenuCenter(inside: superView)
        superView.addSubview(menuView)
        menuView.open()
        isOpened = true
    }
    
    /// Updates the center of the menu just in case the user
    /// uses landscape orientation of the phone
    /// - Parameter superView: the super view that the menu will
    ///     be present in
    private func updateMenuCenter(inside superView: UIView) {
        let centerY = superView.center.y
        let centerX = superView.bounds.width * menuLeftPaddingPercent
        menuView.center = CGPoint(x: centerX, y: centerY)
    }
    
    /// Removes the menu from the super view
    func remove() {
        menuView.close(inCompletion: {
            self.menuView.removeFromSuperview()
            self.isOpened = false
        })
    }
    
}
