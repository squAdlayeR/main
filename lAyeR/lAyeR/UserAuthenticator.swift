//
//  UserAuthenticator.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseAuth

class UserAuthenticator {
    
    static let instance = UserAuthenticator()
    
    func createUser(email: String, password: String, completion: AuthenticationCallback?) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signInUser(email: String, password: String, completion: AuthenticationCallback?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func sendEmailVerification(completion: FIRSendEmailVerificationCallback?) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: completion)
    }
    
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error as Error {
            print(error.localizedDescription)
        }
    }
    
    var currentUserID: String? {
        return FIRAuth.auth()?.currentUser?.uid
    }
}

typealias AuthenticationCallback = FIRAuthResultCallback
