//
//  UserProfileViewController.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 31/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//
import FBSDKCoreKit
import FBSDKLoginKit
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

    @IBOutlet weak var logoutButton: UIButton!
    var userProfile: UserProfile?
    
    // Connects the route list view
    @IBOutlet weak var routeList: UITableView!
    
    // Connects the avatar
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    // Connects user name and his/her location
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var location: UILabel!
    
    // Connects the back button
    @IBOutlet weak var backButton: UIButton!
    

    var selectedRouteNames: Set<String> = []
    var selectionMode: Bool = false
    /// Defines the vibrancy effect view
    var vibrancyEffectView: UIVisualEffectView!
    
    let dataService = DataServiceManager.instance
    
    override func viewDidLoad() {
        self.setCameraView()
        self.setBlur()
        self.setBackButton()
        LoadingBadge.instance.showBadge(in: view)
        dataService.retrieveUserProfile { profile in
            self.userProfile = profile
            self.setUserInfo()
            self.setRouteList()
            LoadingBadge.instance.hideBadge()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
                routes.append(route)
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
    
    /// Adds the back button into the vibrancy effect view
    private func setBackButton() {
        vibrancyEffectView.contentView.addSubview(backButton)
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
        // TODO: Change after image cropping
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
        userName.text = userProfile?.username
        location.text = userProfile?.email
        view.addSubview(userName)
        vibrancyEffectView.addSubview(location)
        
    }
    
    /// Sets up the route list table
    private func setRouteList() {
        routeList.delegate = self
        routeList.dataSource = self
        routeList.tableFooterView = UIView(frame: .zero)
        view.addSubview(routeList)
        setUpButton(selectButton)
        setUpButton(exportButton)
        setUpButton(logoutButton)
    }
    
    private func setUpButton(_ btn: UIButton) {
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        view.addSubview(btn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfileToDesigner" {
            if let route = sender as? Route, let dest = segue.destination as? RouteDesignerViewController {
                dest.importedRoutes = [route]
            }
        }
    }
}

/**
 An extension that is used to define table view delegate and data source.
 */
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the total number of cells in the data table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfile?.designedRoutes.count ?? 0
    }
    
    /// Creates cells for the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: Magic strings and numbers
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeListCell", for: indexPath) as? RouteListCell ?? RouteListCell()
        cell.routeName.text = userProfile?.designedRoutes[indexPath.item]
        // TODO: To be implemented
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
                self.performSegue(withIdentifier: "userProfileToDesigner", sender: route)
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
    
    func deselectAll() {
        for row in 0..<routeList.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            guard let cell = routeList.cellForRow(at: indexPath) as? RouteListCell,
                let name = cell.routeName.text else { continue }
            cell.checkMark.isHidden = true
            selectedRouteNames.remove(name)
        }
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
