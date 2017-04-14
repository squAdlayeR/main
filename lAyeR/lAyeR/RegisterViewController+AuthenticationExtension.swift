//
//  RegisterViewController+AuthenticationExtension.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import UIKit

/**
 An extension that is used to define interactions with user
 Specifically, register actions
 */
extension RegisterViewController {
    
    /// Handles user registeration request
    @IBAction func registerUser(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        let username = usernameField.text ?? ""
        guard !email.characters.isEmpty
            && !password.characters.isEmpty
            && !passwordConfirm.characters.isEmpty
            && !username.characters.isEmpty else {
                showAlertMessage(message: Messages.fillFieldsMessage)
                return
        }
        guard password == passwordConfirm else {
            showAlertMessage(message: Messages.passwordMismatchMessage)
            return
        }
        guard password.characters.count >= ServerConstants.minimumPasswordLength else {
            showAlertMessage(message: Messages.passwordTooShortMessage)
            return
        }
        LoadingBadge.instance.showBadge(in: view)
        userAuthenticator.createUser(email: email, password: password) {
            (user, error) in
            if let error = error {
                LoadingBadge.instance.hideBadge()
                let errorMessage = self.userAuthenticator.getErrorMessage(error: error)
                self.showAlertMessage(message: errorMessage)
                return
            }
            guard let uid = user?.uid else {
                LoadingBadge.instance.hideBadge()
                self.showAlertMessage(message: Messages.createUserFailureMessage)
                return
            }
            DispatchQueue.global(qos: .background).async {
                let profile = UserProfile(email: email, username: username)
                self.databaseManager.addUserProfileToDatabase(uid: uid, userProfile: profile)
                UserAuthenticator.instance.sendEmailVerification(completion: {
                    error in
                    DispatchQueue.main.async {
                        if error != nil {
                            LoadingBadge.instance.hideBadge()
                            self.showAlertMessage(message: Messages.verificationSentFailureMessage)
                            return
                        }
                        LoadingBadge.instance.hideBadge()
                        self.showAlertMessage(title: Messages.successTitle, message: Messages.verificationSentMessage)
                        // Clear current user session.
                        UserAuthenticator.instance.signOut()
                    }
                })
            }
        }
    }

}
