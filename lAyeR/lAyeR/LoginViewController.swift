//
//  RegisterViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/25.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

/**
 This is a view controller specially for user login.
 This is the first view controller that user will be seeing.
 In this controller, the main functionality is to setup 
 the view.
 */
class LoginViewController: UIViewController {
    
    // Connects outlets of sample input fields
    @IBOutlet weak var emailFieldSample: UITextField!
    @IBOutlet weak var passwordFieldSample: UITextField!
    
    // Connects welcome title and subtitle
    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    
    @IBOutlet weak var FBButtonPlaceHolder: UIButton!
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
    let userAuthenticator: UserAuthenticator = UserAuthenticator.instance
    let databaseManager: DatabaseManager = DatabaseManager.instance
    var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        setupCameraView()
        setupBlurEffect()
        setupText()
        setupFormInput()
        setupButtons()
        setCloseKeyboardAction()
        setUpFBLoginButton()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
    }
    
    /// Adjusts auto layout and sets root view controller here.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.delegate?.window??.rootViewController = self
        configInputTextfields()
        configFBLoginButton()
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
    
    /// Adds all the texts into the main view accordingly
    private func setupText() {
        view.addSubview(welcomeTitle)
        vibrancyEffectView.contentView.addSubview(subtitle)
        vibrancyEffectView.contentView.addSubview(registerHint)
        vibrancyEffectView.contentView.addSubview(orLabel)
    }
    
    /// Sets up the input fields
    private func setupFormInput() {
        setupEmailInput()
        setupPasswordInput()
    }
    
    /// Sets up the email input
    private func setupEmailInput() {
        emailField = createTextField(with: emailFieldSample, and: emailText)
        emailField.keyboardType = .emailAddress
        emailField.delegate = self
    }
    
    /// Sets up the password input
    private func setupPasswordInput() {
        passwordField = createTextField(with: passwordFieldSample, and: passwordText)
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
    }
    
    /// Adjusts the positions of textfields in view did appear.
    private func configInputTextfields() {
        emailField.center = emailFieldSample.center
        passwordField.center = passwordFieldSample.center
        vibrancyEffectView.contentView.addSubview(emailField)
        vibrancyEffectView.contentView.addSubview(passwordField)
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
    
    /// Sets up buttons
    private func setupButtons() {
        setupLoginButton()
        setupRegisterButton()
    }
    
    /// Sets up login button
    private func setupLoginButton() {
        loginButton.layer.cornerRadius = loginButton.bounds.height / 2
        loginButton.layer.masksToBounds = true
        view.addSubview(loginButton)
    }
    
    /// Sets up "sign up" button
    private func setupRegisterButton() {
        registerButton.titleLabel?.textColor = UIColor.yellow
        vibrancyEffectView.contentView.addSubview(registerButton)
    }
}

/**
 An extension of login view controller. It is used to redefine user interactions
 through the keyboard.
 */
extension LoginViewController: UITextFieldDelegate {
    
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

