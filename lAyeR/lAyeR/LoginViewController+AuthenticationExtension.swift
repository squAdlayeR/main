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
            self.showAlertMessage(message: Messages.wrongPasswordMessage)
            return
        case .errorCodeUserDisabled:
            self.showAlertMessage(message: Messages.userDisabledMessage)
            return
        case .errorCodeUserNotFound:
            self.showAlertMessage(message: Messages.userNotFoundMessage)
            return
        case .errorCodeInvalidCredential:
            self.showAlertMessage(message: Messages.invalidCredentialMessage)
            return
        case .errorCodeOperationNotAllowed:
            self.showAlertMessage(message: Messages.operationNotAllowedMessage)
            return
        case .errorCodeEmailAlreadyInUse:
            self.showAlertMessage(message: Messages.emailAlreadyInUseMessage)
            return
        case .errorCodeInternalError:
            self.showAlertMessage(message: Messages.internalErrorMessage)
            return
        default:
            self.showAlertMessage(message: Messages.internalErrorMessage)
            return
        }
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
            self.showAlertMessage(message: "Failed login with Facebook.")
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
