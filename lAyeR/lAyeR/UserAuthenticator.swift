//
//  UserAuthenticator.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

/*
 * User Authenticator is used to authenticate user login/registration/logout activities.
 */
class UserAuthenticator {
    
    /// Returns a singleton instance of UserAuthenticator.
    static let instance = UserAuthenticator()
    
    /// Creates a user with email and password authentication
    /// - Parameters:
    ///     - email: String: registration email
    ///     - password: String: registration password
    ///     - completion: AuthenticationCallback?
    func createUser(email: String, password: String, completion: AuthenticationCallback?) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
    
    /// Signs in a user with email and password authentication
    /// - Parameters:
    ///     - email: String: user email
    ///     - password: String: user password
    ///     - completion: AuthenticationCallback?
    func signInUser(email: String, password: String, completion: AuthenticationCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    /// Returns firebase facebook credential
    func createCredential() -> AuthenticationCredential {
        return FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
    }
    
    /// Signs in a user with credential
    /// - Parameters:
    ///     - credential: FIRAuthenCredential: crendential used
    ///     - completion: AuthenticationCallback?
    func signInUser(with credential: AuthenticationCredential, completion: AuthenticationCallback?) {
        Auth.auth().signIn(with: credential, completion: completion)
    }
    
    /// Sends email verification to a user registered with email
    /// - Parameters:
    ///     - completion: FIRSendEmailVerificationCallback?
    func sendEmailVerification(completion: SendEmailVerificationCallback?) {
        Auth.auth().currentUser?.sendEmailVerification(completion: completion)
    }
    
    /// Signs out a user
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    /// Returns current user
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    /// Returns the error message associated with the authentication error
    /// - Parameters:
    ///     - error: Error: authentication error
    /// - Returns:
    ///     - String: error message
    func getErrorMessage(error: Error) -> String {
        guard let errCode = AuthErrorCode(rawValue: error._code) else {
            return Messages.unknownErrorMessage
        }
        switch errCode {
        case .wrongPassword:
            return Messages.wrongPasswordMessage
        case .userDisabled:
            return Messages.userDisabledMessage
        case .userNotFound:
            return Messages.userNotFoundMessage
        case .invalidCredential:
            return Messages.invalidCredentialMessage
        case .operationNotAllowed:
            return Messages.operationNotAllowedMessage
        case .emailAlreadyInUse:
            return Messages.emailAlreadyInUseMessage
        case .internalError:
            return Messages.internalErrorMessage
        case .invalidEmail:
            return Messages.invalidEmailMessage
        default:
            return Messages.networkErrorMessage
        }
    }
    
    /// Returns true if all fields are non-empty
    /// - Parameters:
    ///     - inputs: [String]: inputs
    /// - Returns:
    ///     - Bool: True if all fields are filled
    func allNonEmpty(_ inputs: [String]) -> Bool {
        for input in inputs {
            if input.characters.isEmpty {
                return false
            }
        }
        return true
    }
    
    /// Returns true if all fields are non-empty
    /// - Parameters:
    ///     - email: String: input email
    ///     - password: String: input password
    ///     - passwordConfirm: String: input password confirmation
    ///     - username: String: input username
    /// - Returns:
    ///     - Bool: True if all fields are filled
    func allNonEmpty(_ email: String, _ password: String, _ passwordConfirm: String, _ username: String) -> Bool {
        return !email.characters.isEmpty
            && !password.characters.isEmpty
            && !passwordConfirm.characters.isEmpty
            && !username.characters.isEmpty
    }
    
    /// Returns true if the passwords match
    /// - Parameters:
    ///     - password: String: input password
    ///     - passwordConfirm: String: input password confirmation
    /// - Returns:
    ///     - Bool: True if password and confirmation are same
    func isPasswordMatch(_ password: String, _ passwordConfirm: String) -> Bool {
        return password == passwordConfirm
    }
    
    /// Returns true if the input length is valid within range
    /// - Parameter:
    ///     - input: String: input to check
    /// - Returns:
    ///     - Bool: True if length is within range
    func isValidLength(_ input: String) -> Bool {
        let len = input.characters.count
        return len >= AuthenticationConstants.minimumPasswordLength && len <= AuthenticationConstants.maximumPasswordLength
    }
    
    /// Returns true if the input contains only alphanumeric characters
    /// - Parameter:
    ///     - input: String: input to check
    /// - Returns:
    ///     - Bool: True if only contains alphanumeric characters
    func isValidInput(_ input: String) -> Bool {
        return input.isAlphanumeric
    }
    
}

typealias AuthenticationCredential = AuthCredential
typealias AuthenticationCallback = AuthResultCallback

