//
//  LoginVC+Google.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/27/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import GoogleSignIn

extension LoginVC : GIDSignInUIDelegate, GIDSignInDelegate {
    
    //---------------------------------------------------------------------
    //MARK: - Google init

    func googleInit() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    //---------------------------------------------------------------------
    //MARK: - -Google Login-
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.hideSpinner()
            print("==ERROR:   \(error)")
            return
        }
        let email = user.profile.email ?? ""
        let firstName = user.profile.givenName ?? ""
        let lastName = user.profile.familyName ?? ""
        
        let dimension = round(64 * UIScreen.main.scale)
        var imageURL:String?
        if let imU = user.profile.imageURL(withDimension: UInt(dimension)) {
            imageURL = "\(imU)"
        }
        
        print("|----------------------------------------------------------------------------------------------|")
//        print("Google idToken:\(idToken)")
//        print("Google Full Name:\(fullName)")
//        print("Google id:\(id)")
        print("Google email:\(email)")
        print("Google firstName:\(firstName)")
        print("Google lastName:\(lastName)")
        print("Google imageURL:\(imageURL)")
        print("|----------------------------------------------------------------------------------------------|")
        self.proccessLogin(LoginType.google, email: email, firstName: firstName, lastName: lastName, imageURL: imageURL)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("\nDisconnected SUCCESSFULLY\n")
    }
    
    //---------------------------------------------------------------------
    // MARK: Google Actions
    
    @IBAction func onGoogleLoginButton(_ sender: Any) {
        print("\n Google Login Clicked \n")
        self.showSpinner()
        GIDSignIn.sharedInstance().signIn()
    }
    
}
