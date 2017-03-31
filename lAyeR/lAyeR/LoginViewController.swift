//
//  RegisterViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/25.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseAuth
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    let dataService = DataServiceManager.instance
    
    @IBAction func signInUser(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        guard !email.characters.isEmpty && !password.characters.isEmpty else {
                showErrorAlert(message: "Please fill all fields.")
                return
        }
        dataService.signInUser(email: email, password: password) {
            (user, error) in
            if let error = error {
                self.handleSignInError(error: error)
                return
            }
            self.performSegue(withIdentifier: "loginToAR", sender: nil)
        }
    }
    
    func handleSignInError(error: Error) {
        guard let errCode = FIRAuthErrorCode(rawValue: error._code) else {
            return
        }
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
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
