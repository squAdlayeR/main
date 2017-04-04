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
        let menuButtons = createMenuButtons()
        menuController.addMenuButtons(menuButtons)
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
        return [mapButton, profileButton, settingsButton]
    }
    
    /// Creates a map button
    /// - Returns: a menu button view
    private func createMapButton() -> MenuButtonView {
        let mapButton = MenuButtonView(radius: menuButtonRaidus, iconName: mapIconName)
        // TODO: Add gestures
        return mapButton
    }
    
    /// Creates a settings button
    /// - Returns: a menu button view
    private func createSettingsButton() -> MenuButtonView {
        let profileButton = MenuButtonView(radius: menuButtonRaidus, iconName: settingsIconName)
        // TODO: Add gestures
        return profileButton
    }
    
    /// Creates a profile button
    /// - Returns: a menu button view
    private func createProfileButton() -> MenuButtonView {
        let settingsButton = MenuButtonView(radius: 50, iconName: profileIconName)
        // TODO: Add gestures
        return settingsButton
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







