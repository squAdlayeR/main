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
        prepareUpdateSuccessAlert()
        let menuButtons = createMenuButtons()
        menuController.addMenuButtons(menuButtons)
    }
    
    /// Prepares the updated successful alert
    private func prepareUpdateSuccessAlert() {
        let alertFrame = CGRect(x: 0, y: 0, width: suggestedPopupWidth, height: suggestedPopupHeight)
        updateSuccessAlertController = BasicAlertController(title: "Success", frame: alertFrame)
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
        label.text = "Current location have been updated!"
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
    
    func closeSuccessAlert() {
        updateSuccessAlertController.closeAlert()
        geoManager.forceUpdateUserNearbyPOIS()
        geoManager.forceUpdateUserPoint()
    }
    
    /// Creates necessary buttons in the menu. This includes
    /// - Map button that will navigate users to designer view
    /// - profile button that will navigate users to profile view
    /// - settings button that will naviage users to app settings view
    /// - Returns: the corresponding buttons
    private func createMenuButtons() -> [MenuButtonView] {
        let mapButton = createMapButton()
        let miniMapButton = createMiniMapButton()
        let profileButton = createProfileButton()
        let settingsButton = createSettingsButton()
        let refreshButton = createRefreshButton()
        return [mapButton, miniMapButton, profileButton, settingsButton, refreshButton]
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
    
    /// Creates a button that would be used to toggle mini map
    /// - Returns: a mini map toggle button
    private func createMiniMapButton() -> MenuButtonView {
        let miniMapButton = MenuButtonView(radius: menuButtonRaidus, iconName: miniMapIconName)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMiniMap))
        miniMapButton.addGestureRecognizer(tap)
        return miniMapButton
    }
    
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
    
    /// Toggles the mini map
    func toggleMiniMap() {
        miniMapController.toggleMiniMap()
    }
    
    func forceUpdateLocation() {
        menuController.remove()
        updateSuccessAlertController.presentAlert(within: view)
        view.bringSubview(toFront: updateSuccessAlertController.alertView)
        geoManager.forceUpdateUserPoint()
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







