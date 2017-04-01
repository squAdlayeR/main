//
//  RegisterViewController.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/25.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import FirebaseAuth
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

/**
 This is a view controller specially for user login.
 This is the first view controller that user will be seeing.
 In this controller, the main functionality is to setup 
 the view.
 */
class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }

    
    // Connects outlets of sample input fields
    @IBOutlet weak var emailFieldSample: UITextField!
    @IBOutlet weak var passwordFieldSample: UITextField!
    
    //let loginButton = FBSDKLoginButton()
    
    
    // Connects welcome title and subtitle
    @IBOutlet weak var welcomeTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    @IBOutlet weak var FBButtonPlaceHolder: UIButton!
    // Connects register hint
    @IBOutlet weak var registerHint: UILabel!
    
    // Connects buttons
    @IBOutlet weak var aloginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    // Defines the view for vibrancy effect
    var vibrancyEffectView: UIVisualEffectView!
    
    // Defines the real input fields
    var emailField: InputTextFeild!
    var passwordField: InputTextFeild!
    
    // Data service instance, used to validate login
    let dataService = DataServiceManager.instance
    
    override func viewDidLoad() {
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        setupCameraView()
        setupBlurEffect()
        setupText()
        setupFormInput()
        setupButtons()
        setCloseKeyboardAction()
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.center = FBButtonPlaceHolder.center
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        view.addSubview(loginButton)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print(FBSDKAccessToken.current().userID)
            //print(FBSDKProfile.current().firstName)
            let request = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name, email"])
            request?.start(completionHandler: { connection, result, error in
                //print(result)
            })
        }
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
    
    /// Adds all the texts into the main view accordingly
    private func setupText() {
        view.addSubview(welcomeTitle)
        vibrancyEffectView.contentView.addSubview(subtitle)
        vibrancyEffectView.contentView.addSubview(registerHint)
    }
    
    /// Sets up the input fields
    private func setupFormInput() {
        setupEmailInput()
        setupPasswordInput()
    }
    
    /// Sets up the email input
    private func setupEmailInput() {
        emailField = createTextField(with: emailFieldSample, and: "email address")
        emailField.keyboardType = .emailAddress
        emailField.delegate = self
        vibrancyEffectView.contentView.addSubview(emailField)
    }
    
    /// Sets up the password input
    private func setupPasswordInput() {
        passwordField = createTextField(with: passwordFieldSample, and: "password")
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
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
        aloginButton.layer.cornerRadius = aloginButton.bounds.height / 2
        aloginButton.layer.masksToBounds = true
        view.addSubview(aloginButton)
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

/**
 An extension of login view controller. It is used to define user login actions
 */
extension LoginViewController {
    
    /// Defines action when user click on "Sign in" button
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
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
    
    /// Handles the error brought from the data service
    /// - Parameter error: the error from data service
    private func handleSignInError(error: Error) {
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
    
    /// Presents alert with error message
    /// - Parameter message: the message to be diplayed on the alert.
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
