//
//  ARViewController_MenuExtension.swift
//  lAyeR
//
//  Created by luoyuyang on 29/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

/**
 An extension that is used to initialize popup menu
 */
extension ARViewController {
    
    /// Prepares the menu. This includes
    /// - prepare gestures
    /// - prepare buttons
    func prepareMenu() {
        prepareMenuGestures()
        prepareMainMenuButton()
        prepareUpdateSuccessAlert()
        let menuButtons = createMenuButtons()
        menuController.addMenuButtons(menuButtons)
    }
    
    /// Prepares the main menu button. When it is clicked, it will toggle the menu
    private func prepareMainMenuButton() {
        let menuButton = MenuButtonView(radius: menuButtonRaidus, iconName: menuButtonIcon)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        menuButton.addGestureRecognizer(tap)
        mainMenuButton = menuButton
        mainMenuButton.center = CGPoint(x: view.bounds.width * menuLeftPaddingPercent,
                                        y: view.bounds.height - view.bounds.width * menuLeftPaddingPercent)
        view.addSubview(mainMenuButton)
    }
    
    /// Prepares the updated successful alert
    private func prepareUpdateSuccessAlert() {
        let alertFrame = CGRect(x: 0, y: 0, width: suggestedPopupWidth, height: suggestedPopupHeight)
        updateSuccessAlertController = BasicAlertController(title: successTitle, frame: alertFrame)
        updateSuccessAlertController.alertView.center = view.center
        let closeButton = createCloseButton()
        updateSuccessAlertController.addButtonToAlert(closeButton)
        let label = createSuccessText()
        updateSuccessAlertController.addViewToAlert(label)
    }
    
    /// Creates a text field that shows success message
    /// - Returns: a ui label with success text
    private func createSuccessText() -> UILabel {
        let label = UILabel()
        label.text = locationUpdateSuccessText
        label.font = UIFont(name: alterDefaultFontLight, size: buttonFontSize)
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        return label
    }
    
    /// Creates a close button
    /// - Returns: a close button which will close the popup if it is clicked
    private func createCloseButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle(confirmLabelText, for: .normal)
        newButton.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: buttonFontSize)
        newButton.addTarget(self, action: #selector(closeSuccessAlert), for: .touchUpInside)
        return newButton
    }
    
    /// Creates necessary buttons in the menu. This includes
    /// - Map button that will navigate users to designer view
    /// - profile button that will navigate users to profile view
    /// - settings button that will naviage users to app settings view
    /// - Returns: the corresponding buttons
    private func createMenuButtons() -> [MenuButtonView] {
        let mapButton = createMapButton()
        let profileButton = createProfileButton()
        let settingsButton = createSettingsButton()
        let refreshButton = createRefreshButton()
        return [mapButton, profileButton, settingsButton, refreshButton]
    }
    
    /// Creates a map button
    /// - Returns: a menu button view
    private func createMapButton() -> MenuButtonView {
        let mapButton = MenuButtonView(radius: menuButtonRaidus, iconName: designerIconName)
        let tap = UITapGestureRecognizer(target: self, action: #selector(openDesigner))
        mapButton.addGestureRecognizer(tap)
        return mapButton
    }
    
    /// Creates a settings button
    /// - Returns: a menu button view
    private func createSettingsButton() -> MenuButtonView {
        let settingsButton = MenuButtonView(radius: menuButtonRaidus, iconName: settingsIconName)
        let tap = UITapGestureRecognizer(target: self, action: #selector(openAppSettings))
        settingsButton.addGestureRecognizer(tap)
        return settingsButton
    }
    
    /// Creates a profile button
    /// - Returns: a menu button view
    private func createProfileButton() -> MenuButtonView {
        let profileButton = MenuButtonView(radius: menuButtonRaidus, iconName: profileIconName)
        let tap = UITapGestureRecognizer(target: self, action: #selector(openUserProfile))
        profileButton.addGestureRecognizer(tap)
        return profileButton
    }
    
    /// Creates a refresh button for updating people current locations
    /// - Returns: a refresh button for update
    private func createRefreshButton() -> MenuButtonView {
        let refreshButton = MenuButtonView(radius: menuButtonRaidus, iconName: "refresh")
        let tap = UITapGestureRecognizer(target: self, action: #selector(forceUpdateLocation))
        refreshButton.addGestureRecognizer(tap)
        return refreshButton
    }
    
    /// Opens the user profile page
    func openUserProfile() {
        menuController.remove()
        self.performSegue(withIdentifier: "arToUserProfile", sender: nil)
    }
    
    /// Opens the app settings page
    func openAppSettings() {
        menuController.remove()
        self.performSegue(withIdentifier: "settingsSegue", sender: nil)
    }
    
    /// Opens the map designer page
    func openDesigner() {
        menuController.remove()
        self.performSegue(withIdentifier: "arToDegisnerSegue", sender: nil)
    }
    
    /// Force updates the user current location and nearby pois
    func forceUpdateLocation() {
        menuController.remove()
        updateSuccessAlertController.presentAlert(within: view)
        view.bringSubview(toFront: updateSuccessAlertController.alertView)
        geoManager.forceUpdateUserPoint()
    }
    
    /// Closes the success alert
    func closeSuccessAlert() {
        updateSuccessAlertController.closeAlert()
        geoManager.forceUpdateUserNearbyPOIS()
        geoManager.forceUpdateUserPoint()
    }
    
    /// Toggles the menu
    func toggleMenu() {
        if menuController.isOpened {
            menuController.remove()
            return
        }
        menuController.present(inside: view)
    }
    
    /// Prepares the gestures to call out / close menu
    private func prepareMenuGestures() {
        let swipeDownAction = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDownGesture(swipeGesture:)))
        let swipeUpAction = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUpGesture(swipeGesture:)))
        swipeUpAction.direction = .up
        swipeDownAction.direction = .down
        view.addGestureRecognizer(swipeDownAction)
        view.addGestureRecognizer(swipeUpAction)
    }
    
    /// Handles swipe down gesture, which will call out menu
    func handleSwipeDownGesture(swipeGesture: UISwipeGestureRecognizer) {
        menuController.present(inside: view)
    }
    
    /// Handles swipe up gesture, which will close menu
    func handleSwipeUpGesture(swipeGesture: UISwipeGestureRecognizer) {
        menuController.remove()
    }
    
}







