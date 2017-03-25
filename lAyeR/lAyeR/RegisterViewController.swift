//
//  RegisterViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/25.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var passwordConfirmField: UITextField!
    
    @IBAction func registerUser(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        guard !email.characters.isEmpty && !password.characters.isEmpty
            && !passwordConfirm.characters.isEmpty else {
                showSignupErrorAlert(message: "Please fill all fields.")
                return
        }
        guard password == passwordConfirm else {
            showSignupErrorAlert(message: "Passwords not match!")
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) {
            (user, error) in
            if error != nil {
                if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .errorCodeEmailAlreadyInUse:
                        self.showSignupErrorAlert(message: "Email already in use.")
                        return
                    case .errorCodeInvalidEmail:
                        self.showSignupErrorAlert(message: "Invalid email!")
                        return
                    default:
                        self.showSignupErrorAlert(message: "Network error.")
                        return
                    }
                }
            }
            //print(user?.email)
            guard let user = user else { return }
            FIRDatabase.database().reference().child("users").child(user.uid).setValue(["username": "Test"])
        }
    }
    
    func showSignupErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
