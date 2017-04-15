//
//  UserProfileViewController+TableViewExtension.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/15.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

/**
 An extension that is used to define table view delegate and data source.
 */
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the number of rows per section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /// Returns the total number of sections in the data table
    func numberOfSections(in tableView: UITableView) -> Int {
        return userProfile?.designedRoutes.count ?? 0
    }
    
    /// Returns the height of header view of each section.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return userProfileHeaderHeight
    }
    
    /// Returns the header view of each section.
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    /// Creates cells for the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryboardConstants.routeListIdentifier, for: indexPath) as? RouteListCell ?? RouteListCell()
        let name = userProfile?.designedRoutes[indexPath.section] ?? ""
        cell.routeName.text = name
        cell.routeName.preferredMaxLayoutWidth = tableView.bounds.width
        cell.routeDescription.preferredMaxLayoutWidth = tableView.bounds.width
        DatabaseManager.instance.getRoute(withName: name) { route in
            guard let route = route else {
                return
            }
            cell.backgroundImage.imageFromUrl(url: route.imagePath)
            cell.routeDescription.text = route.distanceDescription
        }
        return cell
    }
    
    /// Handles row selection event.
    /// If user is in selection mode, show the check mark of the cell and insert cell
    /// information into selected names to prepare for export. Otherwise, performs segue 
    /// to route designer to display the selected route.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RouteListCell, let name = cell.routeName.text else {
                return
        }
        if selectionMode {
            cell.checkMark.isHidden = false
            selectedRouteNames.insert(name)
            return
        }
        LoadingBadge.instance.showBadge(in: view)
        DatabaseManager.instance.getRoute(withName: name) { route in
            LoadingBadge.instance.hideBadge()
            guard let route = route else {
                self.showAlertMessage(message: Messages.loadRouteFailureMessage)
                return
            }
            self.performSegue(withIdentifier: StoryboardConstants.userProfileToDesignerSegue, sender: route)
        }
    }
    
    /// Handles row deselection event.
    /// Only valid for selection mode. When user deselects a row, hides the checkmark
    /// of the cell and remove its entry from the set of selected cells.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RouteListCell, let name = cell.routeName.text , selectionMode else {
            return
        }
        cell.checkMark.isHidden = true
        selectedRouteNames.remove(name)
    }
    
    /// Handles row delete event.
    /// Reloads tableview data and updates user profile on cloud.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        guard let currentUser = UserAuthenticator.instance.currentUser, let userProfile = userProfile else {
            return
        }
        let routeName = userProfile.designedRoutes[indexPath.section]
        let uid = currentUser.uid
        userProfile.removeDesignedRoute(indexPath.section)
        tableView.deleteSections(IndexSet(integer: indexPath.section), with:UITableViewRowAnimation.left)
        DatabaseManager.instance.removeRouteFromDatabase(routeName: routeName)
        DatabaseManager.instance.updateUserProfile(uid: uid, userProfile: userProfile)
    }
    
    /// Deselects all rows in the route list.
    func deselectAll() {
        for sec in 0..<routeList.numberOfSections {
            let indexPath = IndexPath(row: 0, section: sec)
            routeList.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
