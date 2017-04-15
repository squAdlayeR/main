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
extension LoginViewController: FBSDKLoginButtonDelegate {
    
    /// Sets up facebook login button.
    func setUpFBLoginButton() {
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = AuthenticationConstants.fbPermissions
    }
    
    /// Positions facebook login button with auto layout in view did appear.
    func configFBLoginButton() {
        fbLoginButton.center = FBButtonPlaceHolder.center
        view.addSubview(fbLoginButton)
    }
    
    /// Processes user interaction and handles facebook authentication.
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        /// If user cancels permission, cancel login actions.
        if result.isCancelled {
            return
        }
        /// If error occurs, show error message.
        if error != nil {
            self.showAlertMessage(message: Messages.fbSignInFailureMessage)
            return
        }
        /// Creates facebook login token.
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        LoadingBadge.instance.showBadge(in: view)
        /// Clears facebook user session.
        FBSDKLoginManager().logOut()
        /// Signs in user or does error handling if error occurs.
        signInUser(with: credential)
    }
    
    /// Signs in the user with facebook credential.
    /// - Parameter crendential: Facebook authentication credential.
    private func signInUser(with credential: FIRAuthCredential) {
        userAuthenticator.signInUser(with: credential) { (user, error) in
            if let error = error {
                self.handleError(error: error)
                return
            }
            guard user != nil else {
                LoadingBadge.instance.hideBadge()
                self.showAlertMessage(message: Messages.fbSignInFailureMessage)
                return
            }
            self.databaseManager.createFBUserProfile()
            LoadingBadge.instance.hideBadge()
            self.performSegue(withIdentifier: StoryboardConstants.loginToARSegue, sender: nil)
        }
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
    
    /// Defines action when user click on "Sign in" button
    @IBAction func signInUser(_ sender: Any) {
        /// Checks input fields, if empty prompts error alert, otherwise proceeds.
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        guard userAuthenticator.allNonEmpty([email, password]) else {
            showAlertMessage(message: Messages.fillFieldsMessage)
            return
        }
        /// Signs in user with input email and password.
        LoadingBadge.instance.showBadge(in: view)
        userAuthenticator.signInUser(email: email, password: password) {
            (user, error) in
            if let error = error {
                self.handleError(error: error)
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
            self.performSegue(withIdentifier: StoryboardConstants.loginToARSegue, sender: nil)
        }
    }
    
    /// Handles error during sign in.
    /// - Parameter error: occurred error.
    func handleError(error: Error) {
        LoadingBadge.instance.hideBadge()
        let errorMessage = userAuthenticator.getErrorMessage(error: error)
        showAlertMessage(message: errorMessage)
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}

}
