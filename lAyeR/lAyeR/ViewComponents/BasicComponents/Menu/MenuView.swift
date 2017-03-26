//
//  MenuView.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 26/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 A class that is used to define a raw menu view. This menu view is reusable,
 is can be used in any conditions. It has the following properties:
 - buttons are listed down in a column
 - when menu is called out, it will have a spring effect with every button moves
    from top to button
 - when menu is closed, it will have a reversed animation as opening
 - buttons are customized
 - buttons has a specifed gap between each other
 */
class MenuView: UIView {
    
    /// Adds buttons to the menu
    /// - Parameter menuButtons: the buttons that will be added into
    ///     the menu
    func addButtons(_ menuButtons: [UIView]) {
        for menuButton in menuButtons {
            addButton(menuButton)
        }
    }

    /// Adds a button in the menu
    /// - Parameter menuButton: the button that will be added into
    ///     the menu
    /// - Note: to do this, we need to stack the button first and then
    ///     resize the frame of the menu
    private func addButton(_ menuButton: UIView) {
        stackButtonView(menuButton)
        resizeFrame()
    }
    
    /// Inserts a button view into the menu stack
    /// - Parameter button: the button that is to be inserted
    private func stackButtonView(_ button: UIView) {
        if let lastButton = self.subviews.last {
            let newFrame = CGRect(x: button.frame.origin.x,
                                  y: lastButton.frame.origin.y + lastButton.bounds.height + buttonGap,
                                  width: button.bounds.width,
                                  height: button.bounds.height)
            button.frame = newFrame
        }
        self.addSubview(button)
    }
    
    /// Resizes the frame so that it will hold all the buttons
    private func resizeFrame() {
        guard var exactRect = self.subviews.first?.frame else { return }
        for subView in self.subviews {
            exactRect = exactRect.union(subView.frame)
        }
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: exactRect.width,
                            height: exactRect.height)
    }
    
    /// Opens the menu
    /// - Note: need to preprocess so that it is in the initial state
    func open() {
        preprocess()
        for (index, button) in self.subviews.reversed().enumerated() {
            UIView.animate(withDuration: menuAnimatingDuration,
                           delay: menuButtonAnimationDelay * Double(index),
                           usingSpringWithDamping: menuSpringCoefficient,
                           initialSpringVelocity: 0, animations: {
                button.alpha = 1
                button.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    
    /// Preprocesses the buttons to be their initial states:
    /// - alpha is zero
    /// - some distance above their diplay positions
    private func preprocess() {
        for buttons in self.subviews {
            buttons.alpha = 0
            buttons.transform = CGAffineTransform(translationX: 0, y: -menuHeight)
        }
    }
    
    /// Closes the menu
    /// - Parameter inCompletion: the callback function that will
    ///     be called after the animation is finished
    func close(inCompletion: @escaping () -> Void) {
        for (index, button) in self.subviews.enumerated() {
            UIView.animate(withDuration: menuAnimatingDuration,
                           delay: menuButtonAnimationDelay * Double(index),
                           usingSpringWithDamping: menuSpringCoefficient,
                           initialSpringVelocity: 0, animations: {
                button.alpha = 0
                button.transform = CGAffineTransform(translationX: 0, y: -self.menuHeight)
            }, completion: { isFinished in
                inCompletion()
            })
        }
    }
    
    /// Calculates the height of the menu
    private var menuHeight: CGFloat {
        return self.bounds.height
    }

}
