//
//  LoginViewController+FBSDKLoginButtonExtension.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

/**
 An extension of login view controller. It is used to define user login actions
 */
extension LoginViewController {
    
    /// Defines action when user click on "Sign in" button
    @IBAction func signInUser(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        guard !email.characters.isEmpty && !password.characters.isEmpty else {
            showAlertMessage(message: Messages.fillFieldsMessage)
            return
        }
        LoadingBadge.instance.showBadge(in: view)
        dataService.signInUser(email: email, password: password) {
            (user, error) in
            if let error = error {
                LoadingBadge.instance.hideBadge()
                self.handleSignInError(error: error)
                return
            }
            guard let user = user else {
                LoadingBadge.instance.hideBadge()
                self.showAlertMessage(message: Messages.signInFailureMessage)
                return
            }
            guard user.isEmailVerified else {
                LoadingBadge.instance.hideBadge()
                self.showAlertMessage(message: Messages.verifyEmailMessage)
                return
            }
            LoadingBadge.instance.hideBadge()
            self.performSegue(withIdentifier: "loginToAR", sender: nil)
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    
    /// Handles the error brought from the data service
    /// - Parameter error: the error from data service
    func handleSignInError(error: Error) {
        guard let errCode = FIRAuthErrorCode(rawValue: error._code) else {
            return
        }
        switch errCode {
        case .errorCodeWrongPassword:
            self.showErrorAlert(message: "Wrong password.")
            return
        case .errorCodeUserDisabled:
            self.showErrorAlert(message: "User disabled.")
            return
        case .errorCodeUserNotFound:
            self.showErrorAlert(message: "User not found.")
            return
        case .errorCodeInvalidCredential:
            self.showErrorAlert(message: "Invalid credential.")
            return
        case .errorCodeOperationNotAllowed:
            self.showErrorAlert(message: "Operation not allowed.")
            return
        case .errorCodeEmailAlreadyInUse:
            self.showErrorAlert(message: "Email already in use.")
            return
        case .errorCodeInternalError:
            self.showErrorAlert(message: "Internal error occured.")
            return
        default:
            self.showErrorAlert(message: "Network error.")
            return
        }
    }
    
    /// Presents alert with error message
    /// - Parameter message: the message to be diplayed on the alert.
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}


extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func setUpFBLoginButton() {
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    func configFBLoginButton() {
        fbLoginButton.center = FBButtonPlaceHolder.center
        view.addSubview(fbLoginButton)
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if result.isCancelled { return }
        if error != nil {
            self.showErrorAlert(message: "Failed login with Facebook.")
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        LoadingBadge.instance.showBadge(in: view)
        FBSDKLoginManager().logOut()
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            DispatchQueue.global().async {
                if let error = error {
                    LoadingBadge.instance.hideBadge()
                    self.handleSignInError(error: error)
                    return
                }
                guard let user = user else { return }
                DispatchQueue.main.async {
                    
                    DatabaseManager.instance.verifyUserProfile(uid: user.uid) {
                        let profile = UserProfile(email: user.email!, avatarRef: (user.photoURL?.absoluteString)!, username: user.displayName!)
                        self.dataService.addUserProfileToDatabase(uid: user.uid, profile: profile)
                    }
                }
            }
            LoadingBadge.instance.hideBadge()
            self.performSegue(withIdentifier: "loginToAR", sender: nil)
        }
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
}
