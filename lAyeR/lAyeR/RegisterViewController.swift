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
                showErrorAlert(message: "Please fill all fields.")
                return
        }
        guard password == passwordConfirm else {
            showErrorAlert(message: "Passwords not match!")
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) {
            (user, error) in
            if error != nil {
                if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
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
            }
            //print(user?.email)
            guard let user = user else { return }
            let newUserInfo = User(uid: user.uid, email: email, password: password).userInfo
            FIRDatabase.database().reference().child("users").child(user.uid).setValue(newUserInfo)
            self.performSegue(withIdentifier: "registerToAR", sender: nil)
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
