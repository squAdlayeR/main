//
//  UserProfileViewController.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 31/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//
import FBSDKCoreKit
import FBSDKLoginKit
import TOCropViewController
import UIKit

/**
 This is a view controller for displaying user infomation, which includes
 - User name, user location, user avatar
 - List of routes that are designed by this user
    - route name
    - route screen shot
    - route length
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
    
    @IBOutlet weak var notification: UILabel!
    
    let picker = UIImagePickerController()

    var selectedRouteNames: Set<String> = []
    var selectionMode: Bool = false
    /// Defines the vibrancy effect view
    var vibrancyEffectView: UIVisualEffectView!
    
    let dataService = DataServiceManager.instance
    
    override func viewDidLoad() {
        self.setCameraView()
        self.setBlur()
        self.setBackButton()
        picker.delegate = self
        loadProfile()
    }
    
    private func loadProfile() {
        LoadingBadge.instance.showBadge(in: view)
        dataService.retrieveUserProfile { profile, success in
            guard success, let profile = profile else {
                self.notification.isHidden = false
                self.vibrancyEffectView.contentView.addSubview(self.notification)
                LoadingBadge.instance.hideBadge()
                return
            }
            self.notification.isHidden = true
            self.userProfile = profile
            self.setUserInfo()
            self.setRouteList()
            LoadingBadge.instance.hideBadge()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        routeList.rowHeight = UITableViewAutomaticDimension
        routeList.estimatedRowHeight = 150
        routeList.reloadData()
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
        let avatarName = "profile.png"
        // TODO: Change after image cropping
        if let url = userProfile?.avatarRef {
            avatar.imageFromUrl(url: url)
        } else {
            avatar.image = UIImage(named: avatarName)
        }
        avatar.layer.cornerRadius = avatar.bounds.height / 2
        avatar.layer.masksToBounds = true
        avatar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeIcon))
        avatar.addGestureRecognizer(tap)
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
        routeList.reloadData()
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
    
    @IBAction func unwindFromRouteDesigner(segue: UIStoryboardSegue) {}
    
    @IBAction func unwindSegueToUserProfile(segue: UIStoryboardSegue) {}
}





