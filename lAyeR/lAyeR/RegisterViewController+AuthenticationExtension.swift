//
//  RegisterViewController+AuthenticationExtension.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 An extension that is used to define interactions with user
 Specifically, register actions
 */
extension RegisterViewController {
    
    /// Handles user registeration request
    @IBAction func registerUser(_ sender: Any) {
        /// Gathers user input data.
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        let username = usernameField.text ?? ""
        /// Checks if any field is empty, show error alert.
        /// Proceeds otherwise.
        guard userAuthenticator.allNonEmpty([email, password, passwordConfirm, username]) else {
                showAlertMessage(message: Messages.fillFieldsMessage)
                return
        }
        /// Checks if password and password confirmation matches.
        /// If mismatch, show error alert. Proceeds otherwise.
        guard userAuthenticator.isPasswordMatch(password, passwordConfirm) else {
            showAlertMessage(message: Messages.passwordMismatchMessage)
            return
        }
        /// Checks if password has a valid length.
        /// If invalid, show error alert. Proceeds otherwise.
        guard userAuthenticator.isValidLength(password) else {
            showAlertMessage(message: Messages.inputLengthMessage)
            return
        }
        /// Checks if user input contains only alphanumeric characters.
        /// If not, show error alert. Proceeds otherwise.
        guard userAuthenticator.isValidInput(password) && userAuthenticator.isValidInput(username) else {
            showAlertMessage(message: Messages.inputFormatMessage)
            return
        }
        
        /// Presents loading badge and requests to create user.
        LoadingBadge.instance.showBadge(in: view)
        createUser(email: email, password: password, username: username)
    }
    
    /// Sends request and prepare error handler to handle errors.
    /// - Parameters:
    ///     - email: String: registration email.
    ///     - password: String: registration password.
    ///     - username: String: user specified user name.
    private func createUser(email: String, password: String, username: String) {
        dataService.createUser(email: email, password: password, username: username, registrationHandler: handleRegistration(user:error:), verificationHandler: handleSendVerificationEmail(error:))
    }
    
    /// Handles error arisen during registration, and verifies if the 
    /// user is created.
    /// - Parameters:
    ///     - user: User?: returns instance of firebase user if succeeded,
    ///                    nil otherwise.
    ///     - error: Error?: error occurs during registration.
    private func handleRegistration(user: User?, error: Error?) {
        if let error = error {
            handleError(error: error)
            return
        }
        guard user != nil else {
            LoadingBadge.instance.hideBadge()
            showAlertMessage(message: Messages.createUserFailureMessage)
            return
        }
    }
    
    /// Handles the feedback from sending verification email.
    /// Parameter error: the error occured during sending verification.
    private func handleSendVerificationEmail(error: Error?) {
        if let error = error {
            handleError(error: error)
            return
        }
        LoadingBadge.instance.hideBadge()
        showAlertMessage(title: Messages.successTitle, message: Messages.verificationSentMessage)
        /// Clear current user session.
        userAuthenticator.signOut()
    }
    
    /// Handles occuring error.
    /// Parameter error: Error occurred.
    private func handleError(error: Error) {
        LoadingBadge.instance.hideBadge()
        let errorMessage = userAuthenticator.getErrorMessage(error: error)
        showAlertMessage(message: errorMessage)
    }

}
