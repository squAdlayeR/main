//
//  RegisterViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/25.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseAuth
import UIKit

/**
 This is a view controller specially for user login.
 This is the first view controller that user will be seeing.
 */
class LoginViewController: UIViewController {
    
    // Connects outlets of sample input fields
    @IBOutlet weak var emailFieldSample: UITextField!
    @IBOutlet weak var passwordFieldSample: UITextField!
    
    // Connects welcome title and subtitle
    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    // Connects register hint
    @IBOutlet weak var registerHint: UILabel!
    
    // Connects buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    // Defines the view for vibrancy effect
    var vibrancyEffectView: UIVisualEffectView!
    
    // Defines the real input fields
    var emailField: InputTextFeild!
    var passwordField: InputTextFeild!
    
    // Data service instance, used to validate login
    let dataService = DataServiceManager.instance
    
    override func viewDidLoad() {
        setupCameraView()
        setupBlurEffect()
        setupText()
        setupFormInput()
        setupButtons()
    }
    
    private func setupCameraView() {
        let cameraViewController = CameraViewController()
        cameraViewController.view.frame = view.bounds
        view.addSubview(cameraViewController.view)
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        
        blurEffectView.frame = view.bounds
        vibrancyEffectView.frame = blurEffectView.bounds
        
        self.vibrancyEffectView = vibrancyEffectView
        blurEffectView.contentView.addSubview(self.vibrancyEffectView)
        view.addSubview(blurEffectView)
    }
    
    private func setupText() {
        view.addSubview(welcomeTitle)
        vibrancyEffectView.contentView.addSubview(subtitle)
        vibrancyEffectView.contentView.addSubview(registerHint)
    }
    
    private func setupFormInput() {
        setupEmailInput()
        setupPasswordInput()
    }
    
    private func setupEmailInput() {
        emailField = createTextFeild(with: emailFieldSample, and: "email address")
        emailField.keyboardType = .emailAddress
        emailField.delegate = self
        vibrancyEffectView.contentView.addSubview(emailField)
    }
    
    private func setupPasswordInput() {
        passwordField = createTextFeild(with: passwordFieldSample, and: "password")
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        vibrancyEffectView.contentView.addSubview(passwordField)
    }
    
    private func setupButtons() {
        setupLoginButton()
        setupRegisterButton()
    }
    
    private func setupLoginButton() {
        loginButton.layer.cornerRadius = loginButton.bounds.height / 2
        loginButton.layer.masksToBounds = true
        view.addSubview(loginButton)
    }
    
    private func setupRegisterButton() {
        registerButton.titleLabel?.textColor = UIColor.yellow
        vibrancyEffectView.contentView.addSubview(registerButton)
    }
    
    private func createTextFeild(with sample: UITextField, and placeHolder: String) -> InputTextFeild {
        let inputSize = CGSize(width: sample.bounds.width, height: 60)
        let newTextFeild = InputTextFeild(placeHolder: placeHolder, size: inputSize)
        newTextFeild.center = sample.center
        return newTextFeild
    }
    
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
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}

extension LoginViewController {
    
    
    
}
