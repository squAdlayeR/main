//
//  UserProfileViewController.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 31/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

/**
 This is a view controller for displaying user infomation, which includes
 - User name, user location, user avatar
 - List of routes that are designed by this user
    - route name
    - route screen shot
    - route description
 These information could be retrieved when view is loaded
 */
class UserProfileViewController: UIViewController {

    // Just for testing perpose. You can modify this as you wish
    //let routeData = [["Walk from pgp to science", "21 March, 2017", "test.png"],
      //              ["Walk from pgp to biz", "20 March, 2017", "test2.png"],
       //             ["Walk from biz to computing", "20 March, 2017", "test3.png"],
       //             ["Walk from computing to clb", "19 March 2017", //"test4.png"],
        //            ["Walk from computing to engining", "18 March 2017", "test2.png"]]
   // let userData = ["Yang Zhuohan", "Singapore, Singapore", ""]
    var userProfile: UserProfile?
    
    // Connects the route list view
    @IBOutlet weak var routeList: UITableView!
    
    // Connects the avatar
    @IBOutlet weak var avatar: UIImageView!
    
    // Connects user name and his/her location
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var location: UILabel!
    
    /// Defines the vibrancy effect view
    var vibrancyEffectView: UIVisualEffectView!
    
    let dataService = DataServiceManager.instance
    
    override func viewDidLoad() {
        dataService.retrieveUserProfile { profile in
            self.userProfile = profile
            //super.viewDidLoad()
            self.setCameraView()
            self.setBlur()
            self.setUserInfo()
            self.setRouteList()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Sets the camera view as backgound image
    private func setCameraView() {
        let cameraViewController = CameraViewController()
        cameraViewController.view.frame = view.bounds
        view.addSubview(cameraViewController.view)
    }
    
    /// Sets the blur effect over the background
    private func setBlur() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffect.frame = view.bounds
        let vibrancyEffect = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark)))
        vibrancyEffect.frame = blurEffect.bounds
        self.vibrancyEffectView = vibrancyEffect
        blurEffect.contentView.addSubview(vibrancyEffect)
        view.addSubview(blurEffect)
    }
    
    /// Sets up the user infomation at the top
    private func setUserInfo() {
        setUserAvata()
        setUserText()
    }
    
    /// Sets the user avata to be the correct image and place it at the
    /// correct place
    private func setUserAvata() {
        
        // TODO: magic string and magic number
        let avatarName = "profilePlaceholder.png"
        //if userData[2] != "" {
            //avatarName = userData[2]
        //}
        if userProfile?.avatarRef != avatarName {
            avatar.imageFromUrl(url: (userProfile?.avatarRef)!)
        } else {
            avatar.image = UIImage(named: avatarName)
        }
        avatar.layer.cornerRadius = avatar.bounds.height / 2
        avatar.layer.masksToBounds = true
        view.addSubview(avatar)
    }
    
    /// Sets user related texts including user name and location info
    private func setUserText() {
        userName.text = userProfile?.username//userData[0]
        location.text = userProfile?.email//userData[1]
        view.addSubview(userName)
        vibrancyEffectView.addSubview(location)
    }
    
    /// Sets up the route list table
    private func setRouteList() {
        routeList.delegate = self
        routeList.dataSource = self
        routeList.tableFooterView = UIView(frame: .zero)
        view.addSubview(routeList)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

/**
 An extension that is used to define table view delegate and data source.
 */
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the total number of cells in the data table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfile?.designedRoutes.count ?? 0//routeData.count
    }
    
    /// Creates cells for the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: Magic strings and numbers
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeListCell", for: indexPath) as! RouteListCell
        cell.routeName.text = userProfile?.designedRoutes[indexPath.item]//routeData[indexPath.item][0]
        //cell.routeDescription.text = routeData[indexPath.item][1]
        //cell.backgroundImage.image = UIImage(named: routeData[indexPath.item][2])
        return cell
    }
    
}

extension UIImageView {
    public func imageFromUrl(url: String) {
        let url = URL(string: url)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
    }
}
