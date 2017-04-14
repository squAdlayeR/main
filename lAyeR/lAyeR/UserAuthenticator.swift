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

class UserAuthenticator {
    
    /// Returns an instance of UserAuthenticator.
    static let instance = UserAuthenticator()
    
    
    /// Creates a user with email and password authentication.
    /// Adds the user profile to database and send verification email.
    func createUser(email: String, password: String, username: String, registrationHandler: @escaping AuthenticationCallback, verificationHandler: @escaping FIRSendEmailVerificationCallback) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password) {
            user, error in
            registrationHandler(user, error)
            guard let uid = user?.uid else { return }
            DispatchQueue.global(qos: .background).async {
                let profile = UserProfile(email: email, username: username)
                DatabaseManager.instance.addUserProfileToDatabase(uid: uid, userProfile: profile)
                self.sendEmailVerification(completion: { error in
                    DispatchQueue.main.async {
                        verificationHandler(error)
                    }
                })
            }
        }
    }
    
    
    
    /// Signs in a user with email and password authentication.
    func signInUser(email: String, password: String, completion: AuthenticationCallback?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func signInUser(with credential: FIRAuthCredential, completion: AuthenticationCallback?) {
        FIRAuth.auth()?.signIn(with: credential, completion: completion)
    }
    
    /// Sends email verification to a user registered with email.
    func sendEmailVerification(completion: FIRSendEmailVerificationCallback?) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: completion)
    }
    
    /// Signs out a user.
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error as Error {
            print(error.localizedDescription)
        }
    }
    
    /// Returns current user.
    var currentUser: FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    
    func getErrorMessage(error: Error) -> String {
        guard let errCode = FIRAuthErrorCode(rawValue: error._code) else {
            return Messages.unknownErrorMessage
        }
        switch errCode {
        case .errorCodeWrongPassword:
            return Messages.wrongPasswordMessage
        case .errorCodeUserDisabled:
            return Messages.userDisabledMessage
        case .errorCodeUserNotFound:
            return Messages.userNotFoundMessage
        case .errorCodeInvalidCredential:
            return Messages.invalidCredentialMessage
        case .errorCodeOperationNotAllowed:
            return Messages.operationNotAllowedMessage
        case .errorCodeEmailAlreadyInUse:
            return Messages.emailAlreadyInUseMessage
        case .errorCodeInternalError:
            return Messages.internalErrorMessage
        case .errorCodeInvalidEmail:
            return Messages.invalidEmailMessage
        default:
            return Messages.internalErrorMessage
        }
    }
    
}

typealias AuthenticationCallback = FIRAuthResultCallback
typealias User = FIRUser
