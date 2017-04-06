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
 A view controller that is to handle user registeration
 */
class RegisterViewController: UIViewController {
    
    // Defines input fields samples
    @IBOutlet weak var emailFieldSample: UITextField!
    @IBOutlet weak var passwordFieldSample: UITextField!
    @IBOutlet weak var confirmPasswordSample: UITextField!
    @IBOutlet weak var usernameFieldSample: UITextField!
    
    // Connects buttons
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    
    // Connects texts
    @IBOutlet weak var signinHint: UILabel!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    // Defines data service for registeration validation
    let dataService = DataServiceManager.instance
    
    // Defines the view for vibrancy effect
    var vibrancyEffectView: UIVisualEffectView!
    
    // Defines the real input fields
    var usernameField: InputTextFeild!
    var emailField: InputTextFeild!
    var passwordField: InputTextFeild!
    var passwordConfirmField: InputTextFeild!
    
    override func viewDidLoad() {
        setupCameraView()
        setupBlurEffect()
        setupFormInput()
        setupButtons()
        setupText()
        setupText()
        setCloseKeyboardAction()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Sets up the camera view for background image
    private func setupCameraView() {
        let cameraViewController = CameraViewController()
        cameraViewController.view.frame = view.bounds
        view.addSubview(cameraViewController.view)
    }
    
    /// Sets up the blur effect and corresponding vibrancy effect
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
    
    /// Sets up all the form input fields
    private func setupFormInput() {
        setupUsernameInput()
        setupEmailInput()
        setupPasswordInput()
        setupPasswordConfirmInput()
    }
    
    private func setupUsernameInput() {
        usernameField = createTextField(with: usernameFieldSample, and: "username")
        usernameField.delegate = self
        vibrancyEffectView.contentView.addSubview(usernameField)
    }
    
    /// Sets up the email input field
    private func setupEmailInput() {
        emailField = createTextField(with: emailFieldSample, and: "email address")
        emailField.keyboardType = .emailAddress
        emailField.delegate = self
        vibrancyEffectView.contentView.addSubview(emailField)
    }
    
    /// Sets up the password input field
    private func setupPasswordInput() {
        passwordField = createTextField(with: passwordFieldSample, and: "password")
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        vibrancyEffectView.contentView.addSubview(passwordField)
    }
    
    /// Sets up the password confirmation field
    private func setupPasswordConfirmInput() {
        passwordConfirmField = createTextField(with: confirmPasswordSample, and: "confirm password")
        passwordConfirmField.isSecureTextEntry = true
        passwordConfirmField.delegate = self
        vibrancyEffectView.contentView.addSubview(passwordConfirmField)
    }
    
    /// Creates a input field with specified sample fields and their placeholders
    /// - Parameters:
    ///     - sample: the sample field defiend in the story board
    ///     - placeHolder: the place holder of the text field
    /// - Returns: a well defined / styled input text field
    private func createTextField(with sample: UITextField, and placeHolder: String) -> InputTextFeild {
        let inputSize = CGSize(width: sample.bounds.width, height: inputFieldHight)
        let newTextFeild = InputTextFeild(placeHolder: placeHolder, size: inputSize)
        newTextFeild.center = sample.center
        return newTextFeild
    }
    
    /// Sets up buttons including the sign in button and the register button
    private func setupButtons() {
        setupSigninButton()
        setupRegisterButton()
    }
    
    /// Sets up the sign in button (back to sign page)
    private func setupSigninButton() {
        signinButton.titleLabel?.textColor = UIColor.yellow
        vibrancyEffectView.contentView.addSubview(signinButton)
    }
    
    /// Sets up the register button
    private func setupRegisterButton() {
        registerButton.layer.cornerRadius = registerButton.bounds.height / 2
        registerButton.layer.masksToBounds = true
        view.addSubview(registerButton)
    }
    
    /// Sets up all the texts
    private func setupText() {
        view.addSubview(mainTitle)
        vibrancyEffectView.contentView.addSubview(subtitle)
        vibrancyEffectView.contentView.addSubview(signinHint)
    }
    
}

/**
 An extension of login view controller. It is used to redefine user interactions
 through the keyboard.
 */
extension RegisterViewController: UITextFieldDelegate {
    
    /// Defines when return is clicked, keyboard should be hidden
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeKeyboard()
        return true
    }
    
    /// Defines the action that when other places is clicked, keyboard should be dismissed
    func setCloseKeyboardAction() {
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(closeGesture)
    }
    
    /// Dismisses the keyboard
    func closeKeyboard() {
        view.endEditing(true)
    }
    
}

/**
 An extension that is used to define interactions with user
 Specifically, register actions
 */
extension RegisterViewController {
    
    /// Handles user registeration request
    @IBAction func registerUser(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        let username = usernameField.text ?? ""
        guard !email.characters.isEmpty
            && !password.characters.isEmpty
            && !passwordConfirm.characters.isEmpty
            && !username.characters.isEmpty else {
                showErrorAlert(message: "Please fill all fields.")
                return
        }
        guard password == passwordConfirm else {
            showErrorAlert(message: "Passwords not match!")
            return
        }
        guard password.characters.count >= 6 else {
            showErrorAlert(message: "Password should be longer than 6 digits!")
            return
        }
        LoadingBadge.instance.showBadge(in: view)
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
            DispatchQueue.main.async {
                let profile = UserProfile(email: email, username: username)
                self.dataService.addUserProfileToDatabase(uid: uid, profile: profile)
            }
            LoadingBadge.instance.hideBadge()
            self.performSegue(withIdentifier: "registerToAR", sender: nil)
        }
    }
    
    /// Handles registeration error.
    /// - Parameter error: the error from user registeration
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
    
    /// Shows alert of corresponding error message
    /// - Parameter message: the message that is to be displayed on the alert
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
