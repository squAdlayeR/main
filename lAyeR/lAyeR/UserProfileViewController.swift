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
    
    func changeIcon() {
        let alert = UIAlertController(title: "Choose Photo from ", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let album = UIAlertAction(title: "My Album", style: .default, handler: { _ in
            self.openAlbum()
        })
        let camera = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        })
        alert.addAction(cancel)
        alert.addAction(album)
        alert.addAction(camera)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.width/2.0, y: self.view.bounds.height, width: 1, height: 1)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        picker.allowsEditing = false
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    func openAlbum() {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
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
            print("here")
            userProfile.designedRoutes.remove(at: indexPath.section)
            print("here")
            //tableView.deleteRows(at: [indexPath], with: .left)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.left)
            // Error handling here
            print("ok")
            DatabaseManager.instance.removeRouteFromDatabase(routeName: name)
            print("ok")
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

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        dismiss(animated: true) {
            let cropper = TOCropViewController(croppingStyle: TOCropViewCroppingStyle.circular, image: pickedImage)
            cropper.delegate = self
            self.present(cropper, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension UserProfileViewController: TOCropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        dismiss(animated: true) { _ in
            self.refreshProfile(with: image)
        }
    }
    
    func refreshProfile(with image: UIImage) {
        do {
            let url = try GPXManager.save(name: "user-icon", image: image)
            self.avatar.imageFromUrl(url: url.absoluteString)
            self.userProfile?.avatarRef = url.absoluteString
            DispatchQueue.global(qos: .background).async {
                DatabaseManager.instance.addUserProfileToDatabase(uid: UserAuthenticator.instance.currentUser!.uid, userProfile: self.userProfile!)
            }
        } catch {
            self.showAlertMessage(message: "Failed to save the icon.")
        }
    }
    
}

extension UIImageView {
    
    public func imageFromUrl(url: String) {
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
    }
}
