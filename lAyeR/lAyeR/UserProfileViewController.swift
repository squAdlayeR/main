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
        super.viewDidAppear(animated)
        configRouteList()
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
        if let url = userProfile?.avatarRef {
            avatar.imageFromUrl(url: url)
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
    
    /// Sets up the route list table.
    private func setRouteList() {
        routeList.delegate = self
        routeList.dataSource = self
        routeList.tableFooterView = UIView(frame: .zero)
        view.addSubview(routeList)
        routeList.reloadData()
    }
    
    /// Postions the route list in view did appear using auto layout
    private func configRouteList() {
        routeList.rowHeight = UITableViewAutomaticDimension
        routeList.estimatedRowHeight = UserProfileConstants.estimatedRowHeight
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
        btn.layer.cornerRadius = UserProfileConstants.defaultButtonCornerRadius
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





