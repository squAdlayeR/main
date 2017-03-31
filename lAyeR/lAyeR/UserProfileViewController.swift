//
//  UserProfileViewController.swift
//  ViewComponentTesting
//
//  Created by Yang Zhuohan on 31/3/17.
//  Copyright © 2017 Yang Zhuohan. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    var vibrancyEffectView: UIVisualEffectView!
    let testData = [["Walk from pgp to science", "21 March, 2017", "test"],
                    ["Walk from pgp to biz", "20 March, 2017", "test2"],
                    ["Walk from biz to computing", "20 March, 2017", "test3"],
                    ["Walk from computing to clb", "19 March 2017", "test4"],
                    ["Walk from computing to engining", "18 March 2017", "test2"]]
    @IBOutlet weak var routeList: UITableView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var location: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCameraView()
        setBlur()
        routeList.delegate = self
        routeList.dataSource = self
        routeList.tableFooterView = UIView(frame: .zero)
        view.addSubview(routeList)
        view.addSubview(userName)
        vibrancyEffectView.addSubview(location)
        avatar.image = UIImage(named: "gakki.png")
        avatar.layer.cornerRadius = avatar.bounds.height / 2
        avatar.layer.masksToBounds = true
        view.addSubview(avatar)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setCameraView() {
        let cameraViewController = CameraViewController()
        cameraViewController.view.frame = view.bounds
        view.addSubview(cameraViewController.view)
    }
    
    private func setBlur() {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffect.frame = view.bounds
        let vibrancyEffect = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark)))
        vibrancyEffect.frame = blurEffect.bounds
        self.vibrancyEffectView = vibrancyEffect
        blurEffect.contentView.addSubview(vibrancyEffect)
        view.addSubview(blurEffect)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

/**
 */
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeListCell", for: indexPath) as! RouteListCell
        
        cell.routeName.text = testData[indexPath.item][0]
        cell.routeDescription.text = testData[indexPath.item][1]
        cell.backgroundImage.image = UIImage(named: testData[indexPath.item][2] + ".png")
       
        return cell
    }
    
}
