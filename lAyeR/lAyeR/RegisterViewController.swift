//
//  RegisterViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/25.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseAuth
import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var passwordConfirmField: UITextField!
    
    let dataService = DataServiceManager.instance
    
    @IBAction func registerUser(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        guard !email.characters.isEmpty && !password.characters.isEmpty
            && !passwordConfirm.characters.isEmpty else {
                showErrorAlert(message: "Please fill all fields.")
                return
        }
        guard password == passwordConfirm else {
            showErrorAlert(message: "Passwords not match!")
            return
        }
        dataService.createUser(email: email, password: password) {
            (user, error) in
            if let error = error {
                self.handleSignUpError(error: error)
                return
            }
            guard let uid = user?.uid else {
                self.showErrorAlert(message: "Failed to create user.")
                return
            }
            let newUser = User(uid: uid, email: email, password: password)
            self.dataService.addUserToDatabase(user: newUser)
            self.performSegue(withIdentifier: "registerToAR", sender: nil)
        }
    }
    
    func handleSignUpError(error: Error) {
        guard let errCode = FIRAuthErrorCode(rawValue: error._code) else {
            return
        }
        switch errCode {
        case .errorCodeEmailAlreadyInUse:
            self.showErrorAlert(message: "Email already in use.")
            return
        case .errorCodeInvalidEmail:
            self.showErrorAlert(message: "Invalid email!")
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
