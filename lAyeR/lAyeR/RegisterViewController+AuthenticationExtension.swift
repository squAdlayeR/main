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
        /// Gathers user input data.
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        let username = usernameField.text ?? ""
        /// Checks if any field is empty, show error alert.
        /// Proceeds otherwise.
        guard allNonEmpty(email, password, passwordConfirm, username) else {
                showAlertMessage(message: Messages.fillFieldsMessage)
                return
        }
        /// Checks if password and password confirmation matches.
        /// If mismatch, show error alert. Proceeds otherwise.
        guard isPasswordMatch(password, passwordConfirm) else {
            showAlertMessage(message: Messages.passwordMismatchMessage)
            return
        }
        /// Checks if password has a valid length.
        /// If invalid, show error alert. Proceeds otherwise.
        guard isValidLength(password) && isValidLength(username) else {
            showAlertMessage(message: Messages.inputLengthMessage)
            return
        }
        /// Checks if user input contains only alphanumeric characters.
        /// If not, show error alert. Proceeds otherwise.
        guard isValidInput(password) && isValidInput(username) else {
            showAlertMessage(message: Messages.inputFormatMessage)
            return
        }
        
        /// Presents loading badge and requests to create user.
        LoadingBadge.instance.showBadge(in: view)
        createUser(email: email, password: password, username: username)
    }
    
    /// Returns true if all fields are non-empty.
    /// - Parameters:
    ///     - email: String: input email
    ///     - password: String: input password
    ///     - passwordConfirm: String: input password confirmation
    ///     - username: String: input username
    /// - Returns:
    ///     - Bool: True if all fields are filled.
    private func allNonEmpty(_ email: String, _ password: String, _ passwordConfirm: String, _ username: String) -> Bool {
        return !email.characters.isEmpty
            && !password.characters.isEmpty
            && !passwordConfirm.characters.isEmpty
            && !username.characters.isEmpty
    }
    
    /// Returns true if the passwords match.
    /// - Parameters:
    ///     - password: String: input password
    ///     - passwordConfirm: String: input password confirmation
    /// - Returns:
    ///     - Bool: True if password and confirmation are same.
    private func isPasswordMatch(_ password: String, _ passwordConfirm: String) -> Bool {
        return password == passwordConfirm
    }
    
    /// Returns true if the input length is valid within range.
    /// - Parameter:
    ///     - input: String: input to check.
    /// - Returns:
    ///     - Bool: True if length is within range.
    private func isValidLength(_ input: String) -> Bool {
        let len = input.characters.count
        return len >= AuthenticationConstants.minimumPasswordLength && len <= AuthenticationConstants.maximumPasswordLength
    }
    
    /// Returns true if the input contains only alphanumeric characters.
    /// - Parameter:
    ///     - input: String: input to check.
    /// - Returns:
    ///     - Bool: True if only contains alphanumeric characters.
    private func isValidInput(_ input: String) -> Bool {
        return input.isAlphanumeric
    }
    
    /// Sends request and prepare error handler to handle errors.
    /// - Parameters:
    ///     - email: String: registration email.
    ///     - password: String: registration password.
    ///     - username: String: user specified user name.
    private func createUser(email: String, password: String, username: String) {
        userAuthenticator.createUser(email: email, password: password, username: username, registrationHandler: handleRegistration(user:error:), verificationHandler: handleSendVerificationEmail(error:))
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
        // Clear current user session.
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
