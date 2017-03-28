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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func signInUser(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        guard !email.characters.isEmpty && !password.characters.isEmpty else {
                showErrorAlert(message: "Please fill all fields.")
                return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password) {
            (user, error) in
            if error != nil {
                if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .errorCodeWrongPassword:
                        self.showErrorAlert(message: "Wrong password.")
                        return
                    case .errorCodeUserDisabled:
                        self.showErrorAlert(message: "User disabled.")
                        return
                    case .errorCodeUserNotFound:
                        self.showErrorAlert(message: "User not found.")
                        return
                    default:
                        self.showErrorAlert(message: "Network error.")
                        return
                    }
                }
            }
            self.performSegue(withIdentifier: "loginToAR", sender: nil)
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
