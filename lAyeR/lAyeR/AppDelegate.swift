//
//  AppDelegate.swift
//  coredatatest
//
//  Created by Victoria Duan on 2017/3/12.
//  Copyright © 2017年 nus.cs3217.a0147967j. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var storyboard: UIStoryboard?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureDependencies(application, launchOptions: launchOptions)
        sleep(AppConfig.launchTime)
        initializeWindow()
        // Checks if user logged in
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            return true
        }
        let isFBUser = !currentUser.providerData.filter({ $0.providerID == AppConfig.FBProviderID }).isEmpty
        guard currentUser.isEmailVerified || isFBUser else {
            return true
        }
        // Reassigns root view controller
        self.window?.rootViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardConstants.arViewControllerIdentifier)
        GPSTracker.instance.start()
        /// Check import segue perform condition
        if let url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL, url.isFileURL {
            self.window?.rootViewController?.performSegue(withIdentifier: StoryboardConstants.arToDesignerImportSegue, sender: url)
        }
        return true
    }
    
    /// Handles open file and facebook login url
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        performImportSegue(url: url)
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //DatabaseManager.instance.connectivityCheckCount = 0
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        // Upload GPS tracking data here.
        GPSTracker.instance.reset()
    }
    
    /// Handles open external url
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        performImportSegue(url: url)
        return true
    }
    
    /// Handles open external url
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        performImportSegue(url: url)
        return true
    }
    
    /// Configure third party sdks
    private func configureDependencies(_ application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        GMSPlacesClient.provideAPIKey(AppConfig.apiKey)
        GMSServices.provideAPIKey(AppConfig.apiKey)
        FIRApp.configure()
        DatabaseManager.instance.startCheckConnectivity()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Initializes window
    private func initializeWindow() {
        self.window?.makeKeyAndVisible()
        self.storyboard = UIStoryboard(name: StoryboardConstants.storyboardIdentifier, bundle: Bundle.main)
    }
    
    /// Handles open external url and segues to route designer to show the route
    /// - Parameter url: URL: url to open
    private func performImportSegue(url: URL) {
        guard url.isFileURL, self.window?.rootViewController is ARViewController else {
            return
        }
        if let presentedViewController = self.window?.rootViewController?.presentedViewController, !(presentedViewController is RouteDesignerViewController) {
            self.window?.rootViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
        }
        self.window?.rootViewController?.performSegue(withIdentifier: StoryboardConstants.arToDesignerImportSegue, sender: url)
    }
}


