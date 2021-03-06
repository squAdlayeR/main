//
//  Messages.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

class Messages {

    // ====== Titles ======
    static let errorTitle: String = "Oops!"
    static let imagePickerTitle: String = "Choose Photo From"
    static let successTitle: String = "Congrats!"
    
    // ====== Action Titles ======
    static let albumTitle: String = "My Album"
    static let cameraTitle: String = "Take Photo"
    static let cancelTitle: String = "Cancel"
    static let selectTitle: String = "Select"

    // ====== Alert Messages ======
    
    //------- I/O -------
    
    static let databaseDisconnectedMessage: String = "Disconnected from database! Cannot save to/load from database!"
    static let databaseWriteFailureMessage: String = "Failed to save changes to database."
    static let loadRouteFailureMessage: String = "Failed to load route."
    static let saveGPXFailureMessage: String = "Failed to save .gpx files."
    static let savePNGFailureMessage: String = "Failed to save user icon."
    static let selectFilesMessage: String = "Please select routes to export."
    
    //------- Authentication -------
    
    /// Login
    static let fbSignInFailureMessage: String = "Failed to sign in with Facebook"
    static let invalidCredentialMessage: String = "Invalid Login Credential."
    static let signInFailureMessage: String = "Failed to sign in."
    static let userDisabledMessage: String = "User Disabled"
    static let userNotFoundMessage: String = "User Not Found."
    static let verifyEmailMessage: String = "Please verify your email."
    static let wrongPasswordMessage: String = "Wrong Password."
    
    /// Register
    static let createUserFailureMessage: String = "Failed to sign up."
    static let inputFormatMessage: String = "Username and password should not be empty and only contain alphanumeric characters and whitespaces."
    static let inputLengthMessage: String = "Password should be longer than or equal to 6 digits and less than or equal to 12 digits."
    static let invalidEmailMessage: String = "Invalid Email."
    static let passwordMismatchMessage: String = "Password Mismatch!"
    static let verificationSentMessage: String = "An email verfication is sent to your email. Please verify your email."
    static let verificationSentFailureMessage: String = "Failed to send verification email."
    
    /// Common
    static let emailAlreadyInUseMessage: String = "Email Already In Use."
    static let fillFieldsMessage: String = "Please fill in all fields."
    static let internalErrorMessage: String = "Internal Error Occurred."
    static let networkErrorMessage: String = "Network Error."
    static let operationNotAllowedMessage: String = "Operation Not Allowed."
    static let unknownErrorMessage: String = "Unknown Error."
    
    /// Naming
    static let invalidNameMessage: String = "Route name should not be empty and only contain alphanumeric characters and whitespaces."

}

