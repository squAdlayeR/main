//
//  UserProfileViewController+UIInteractionExtension.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/15.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

/*
 * This extension of user profile view controller handles user interactions with 
 * buttons in the screen.
 */
extension UserProfileViewController {

    /// Handles logout event.
    @IBAction func logout(_ sender: Any) {
        dataService.signOut()
        self.performSegue(withIdentifier: StoryboardConstants.userProfileToLoginSegue, sender: nil)
    }
    
    /// Handles export event.
    @IBAction func exportPressed(_ sender: UIButton) {
        if selectedRouteNames.isEmpty {
            showAlertMessage(message: Messages.selectFilesMessage)
            return
        }
        LoadingBadge.instance.showBadge(in: view)
        DatabaseManager.instance.getRoutes(with: selectedRouteNames) { routes in
            LoadingBadge.instance.hideBadge()
            self.share(routes: routes)
        }
    }
    
    /// Handles select event.
    @IBAction func selectPressed(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        selectionMode = !selectionMode
        routeList.allowsMultipleSelection = !routeList.allowsMultipleSelection
        if title == Messages.selectTitle {
            sender.setTitle(Messages.cancelTitle, for: .normal)
        } else {
            sender.setTitle(Messages.selectTitle, for: .normal)
            deselectAll()
        }
        selectedRouteNames.removeAll()
    }
    
}
