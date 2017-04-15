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

    @IBAction func logout(_ sender: Any) {
        dataService.signOut()
        self.performSegue(withIdentifier: "userProfileToLogin", sender: nil)
    }
    
    @IBAction func exportPressed(_ sender: UIButton) {
        if selectedRouteNames.isEmpty {
            showAlertMessage(message: "Please select routes to export.")
            return
        }
        LoadingBadge.instance.showBadge(in: view)
        let group = DispatchGroup()
        var routes: [Route] = []
        for name in selectedRouteNames {
            group.enter()
            DatabaseManager.instance.getRoute(withName: name) { route in
                if let route = route {
                    routes.append(route)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            LoadingBadge.instance.hideBadge()
            self.share(routes: routes)
        }
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        if title == "Select" {
            routeList.allowsMultipleSelection = true
            selectionMode = true
            sender.setTitle("Cancel", for: .normal)
        } else {
            routeList.allowsMultipleSelection = false
            sender.setTitle("Select", for: .normal)
            selectionMode = false
            deselectAll()
        }
        selectedRouteNames.removeAll()
    }
    
}
