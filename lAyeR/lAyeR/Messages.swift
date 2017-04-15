//
//  Messages.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/4/14.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

class Messages {

    // ====== Alert Titles ======
    static let errorTitle: String = "Oops!"
    static let successTitle: String = "Congrats!"

    // ====== Alert Messages ======
    
    //------- I/O -------
    
    static let databaseWriteFailureMessage: String = "Disconnected! Cannot save changes to database."
    static let loadRouteFailureMessage: String = "Failed to load route."
    static let saveGPXFailureMessage: String = "Failed to save .gpx files."
    static let savePNGFailureMessage: String = "Failed to save user icon."
    
    
    
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
    static let inputFormatMessage: String = "User input should only contain letters and numbers."
    static let inputLengthMessage: String = "User input should be longer than or equal to 6 digits and less than or equal to 12 digits."
    static let invalidEmailMessage: String = "Invalid Email."
    static let passwordMismatchMessage: String = "Password Mismatch!"
    static let verificationSentMessage: String = "An email verfication is sent to your email. Please verify your email."
    static let verificationSentFailureMessage: String = "Failed to send verfication email."
    
    /// Common
    static let emailAlreadyInUseMessage: String = "Email Already In Use."
    static let fillFieldsMessage: String = "Please fill in all fields."
    static let internalErrorMessage: String = "Internal Error Occurred."
    static let networkErrorMessage: String = "Network Error."
    static let operationNotAllowedMessage: String = "Operation Not Allowed."
    static let unknownErrorMessage: String = "Unknown Error."
    

}

