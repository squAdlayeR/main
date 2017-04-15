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
    - route length
 These information could be retrieved when view is loaded
 */
class UserProfileViewController: UIViewController {
    
    // Connects the route list view
    @IBOutlet weak var routeList: UITableView!
    
    // Connects the avatar
    @IBOutlet weak var avatar: UIImageView!

    // Connects user name and his/her location
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var location: UILabel!
    
    // Connects the buttons
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    
    // Connects the notification label
    @IBOutlet weak var notification: UILabel!

    /// Defines the vibrancy effect view
    var vibrancyEffectView: UIVisualEffectView!
    
    // Defines the image picker
    let picker = UIImagePickerController()
    
    // Defines the selected routes
    var selectedRouteNames: Set<String> = []
    
    // Sets initial selection mode to false
    var selectionMode: Bool = false
    
    // Defines the model of this view controller
    var userProfile: UserProfile?
    
    // Defines the data service used.
    let dataService = DataServiceManager.instance
    
    override func viewDidLoad() {
        setCameraView()
        setBlur()
        setBackButton()
        setUpButtons()
        setUserInfo()
        setRouteList()
        picker.delegate = self
    }
    
    /// Loads the user profile.
    private func loadProfile() {
        LoadingBadge.instance.showBadge(in: view)
        dataService.retrieveUserProfile { profile, success in
            guard success, let profile = profile else {
                self.setNotification()
                LoadingBadge.instance.hideBadge()
                return
            }
            self.loadUserInfo(profile)
            self.notification.isHidden = true
            LoadingBadge.instance.hideBadge()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProfile()
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
    
    /// Adds the notification label into vibrancy effect view
    private func setNotification() {
        notification.isHidden = false
        vibrancyEffectView.contentView.addSubview(self.notification)
    }
    
    /// Sets up the user infomation at the top
    private func setUserInfo() {
        setUserAvatar()
        setUserText()
    }
    
    /// Loads the user info and displays it in the view
    private func loadUserInfo(_ profile: UserProfile) {
        userProfile = profile
        loadUserText()
        loadUserAvatar()
        setRouteList()
    }
    
    /// Sets the user avata to be the correct image and place it at the
    /// correct place
    private func setUserAvatar() {
        avatar.layer.cornerRadius = avatar.bounds.height / 2
        avatar.layer.masksToBounds = true
        avatar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeIcon))
        avatar.addGestureRecognizer(tap)
        view.addSubview(avatar)
    }
    
    /// Loads the user avatar
    private func loadUserAvatar() {
        if let url = userProfile?.avatarRef {
            avatar.imageFromUrl(url: url)
        }
    }
    
    /// Sets user related texts including user name and location info
    private func setUserText() {
        view.addSubview(userName)
        vibrancyEffectView.addSubview(location)
        
    }
    
    /// Loads the user text
    private func loadUserText() {
        userName.text = userProfile?.username
        location.text = userProfile?.email
    }
    
    /// Sets up the route list table.
    private func setRouteList() {
        routeList.delegate = self
        routeList.dataSource = self
        routeList.tableFooterView = UIView(frame: .zero)
        routeList.rowHeight = UITableViewAutomaticDimension
        routeList.estimatedRowHeight = routeListEstimatedRowHeight
        view.addSubview(routeList)
        routeList.reloadData()
    }
    
    /// Sets up the buttons.
    private func setUpButtons() {
        setUpButton(selectButton)
        setUpButton(exportButton)
        setUpButton(logoutButton)
    }
    
    /// Sets up single button.
    private func setUpButton(_ btn: UIButton) {
        btn.layer.cornerRadius = userProfileButtonCornerRadius
        btn.layer.masksToBounds = true
        view.addSubview(btn)
    }
    
    /// Prepares data for storyboard segues.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardConstants.userProfileToDesignerSegue {
            if let route = sender as? Route, let dest = segue.destination as? RouteDesignerViewController {
                dest.importedRoutes = [route]
            }
        }
    }
    
    @IBAction func unwindFromRouteDesigner(segue: UIStoryboardSegue) {}
    
    @IBAction func unwindSegueToUserProfile(segue: UIStoryboardSegue) {}
}





