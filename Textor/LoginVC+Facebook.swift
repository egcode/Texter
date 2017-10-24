//
//  LoginVC+Facebook.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/27/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKCoreKit

extension LoginVC {
    
    //---------------------------------------------------------------------
    //MARK: - Facebook Init

    func facebookInit() {
        if (FBSDKAccessToken.current() != nil) {
            guard let token = FBSDKAccessToken.current().tokenString else {
                print("no token")
                return
            }
            print("TOKEN SAVED = \(token)")
            self.getFacebookGraphAndSegue(token: token)
        } else {
//            self.loginEnabled(true)
        }
    }
    
    //---------------------------------------------------------------------
    //MARK: - Facebook Actions
    
    @IBAction func onFacebookLogin(_ sender: Any) {
        self.showSpinner()
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                self.hideSpinner()
            case .cancelled:
                print("User cancelled login.")
                self.hideSpinner()
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("\nLogged in SUCCESSFULLY!")
                print("\nToken: \(accessToken.authenticationToken)")
                print("\ngrantedPermissions: \(grantedPermissions)")
                print("\ndeclinedPermissions: \(declinedPermissions)")
                
                self.getFacebookGraphAndSegue(token: accessToken.authenticationToken)
            }
        }
    }
    
    //---------------------------------------------------------------------
    // MARK: Facebook
    
    func getFacebookGraphAndSegue(token:String) {
        
        guard let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name, first_name, last_name"], tokenString: token, version: nil, httpMethod: "GET") else {
            self.hideSpinner()
            print("could not get Facebook user info")
            return
        }
        req.start(completionHandler: { (connection, result, error) in
            if(error == nil) {
//                print("result \(result)")
                guard let userInfo = result as? [String: AnyObject] else {magic("bad result");return}
                
//                let fullName = userInfo["name"] as? String ?? ""
                let email = userInfo["email"] as? String ?? ""
                let firstName = userInfo["first_name"] as? String ?? ""
                let lastName = userInfo["last_name"] as? String ?? ""
                
                var imageURL:String?
                if let id = userInfo["id"] as? String {
                    imageURL = "http://graph.facebook.com/\(id)/picture?type=large"
                }
                
                print("|----------------------------------------------------------------------------------------------|")
//                print("Facebook id:\(id)")
                print("Facebook email:\(email)")
                print("Facebook firstName:\(firstName)")
                print("Facebook lastName:\(lastName)")
                print("Facebook imageURL:\(imageURL)")
                print("|----------------------------------------------------------------------------------------------|")
                self.proccessLogin(LoginType.facebook, email: email, firstName: firstName, lastName: lastName, imageURL: imageURL)
            }
            else {
                self.hideSpinner()
                magic("error \(String(describing: error))")
                self.alert("Error Getting data from facebook")
            }
        })
    }
}
