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
    
    /// Returns the total number of cells in the data table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userProfile?.designedRoutes.count ?? 0
    }
    
    /// Creates cells for the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: Magic strings and numbers
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeListCell", for: indexPath) as? RouteListCell ?? RouteListCell()
        
        cell.routeName.text = userProfile?.designedRoutes[indexPath.section]
        cell.routeName.preferredMaxLayoutWidth = tableView.bounds.width
        cell.routeDescription.preferredMaxLayoutWidth = tableView.bounds.width
        
        DatabaseManager.instance.getRoute(withName: cell.routeName.text!) { route in
            if let route = route {
                cell.backgroundImage.imageFromUrl(url: route.imagePath)
                cell.routeDescription.text = "Distance: \(Int(route.distance)) m"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RouteListCell,
            let name = cell.routeName.text else { return }
        if selectionMode {
            cell.checkMark.isHidden = false
            selectedRouteNames.insert(name)
        } else {
            LoadingBadge.instance.showBadge(in: view)
            DatabaseManager.instance.getRoute(withName: name) { route in
                //segue
                LoadingBadge.instance.hideBadge()
                if let route = route {
                    self.performSegue(withIdentifier: "userProfileToDesigner", sender: route)
                } else {
                    self.showAlertMessage(message: "Load route failed!")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RouteListCell,
            let name = cell.routeName.text else { return }
        if selectionMode {
            cell.checkMark.isHidden = true
            selectedRouteNames.remove(name)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //tableView.deleteRows(at: [indexPath], with: .left)
            guard let currentUser = UserAuthenticator.instance.currentUser,
                let userProfile = userProfile else {
                    // might lost connection here, operation can't be done.
                    return
            }
            print("ok")
            print(indexPath)
            let uid = currentUser.uid
            let name = userProfile.designedRoutes[indexPath.section]
            userProfile.designedRoutes.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.left)
            // Error handling here
            DatabaseManager.instance.removeRouteFromDatabase(routeName: name)
            DatabaseManager.instance.updateUserProfile(uid: uid, userProfile: userProfile)
            // Error handling ends here.
        }
    }
    
    func deselectAll() {
        for sec in 0..<routeList.numberOfSections {
            let indexPath = IndexPath(row: 0, section: sec)
            guard let cell = routeList.cellForRow(at: indexPath) as? RouteListCell,
                let name = cell.routeName.text else { continue }
            cell.checkMark.isHidden = true
            selectedRouteNames.remove(name)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
