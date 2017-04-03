//
//  UserAuthenticator.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseAuth

class UserAuthenticator {
    
    /// Returns an instance of UserAuthenticator.
    static let instance = UserAuthenticator()
    
    /// Creates a user with email and password authentication.
    func createUser(email: String, password: String, completion: AuthenticationCallback?) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: completion)
    }
    
    /// Signs in a user with email and password authentication.
    func signInUser(email: String, password: String, completion: AuthenticationCallback?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: completion)
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
    
}

typealias AuthenticationCallback = FIRAuthResultCallback
