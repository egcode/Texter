//
//  ViewController.swift
//  Textor
//
//  Created by eugene golovanov on 8/9/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    //---------------------------------------------------------------------
    //MARK: - Properties
    @IBOutlet weak var buttonFacebookLogin: LoginButton!
    @IBOutlet weak var buttonGoogleLogin: LoginButton!
    
    @IBOutlet weak var tileImageView: TileImageAnimated!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    //---------------------------------------------------------------------
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonFacebookLogin.addTarget(self, action: #selector(LoginVC.onFacebookLogin(_:)), for: .touchUpInside)
        self.buttonGoogleLogin.addTarget(self, action: #selector(LoginVC.onGoogleLoginButton(_:)), for: .touchUpInside)
        
        //Shadow
        imageViewLogo.layer.shadowColor = UIColor.black.cgColor
        imageViewLogo.layer.shadowRadius = 6
        imageViewLogo.layer.shadowOpacity = 0.3
        imageViewLogo.layer.shadowOffset = CGSize(width: 0, height: 4)
        labelTitle.layer.shadowColor = imageViewLogo.layer.shadowColor
        labelTitle.layer.shadowRadius = imageViewLogo.layer.shadowRadius
        labelTitle.layer.shadowOpacity = imageViewLogo.layer.shadowOpacity
        labelTitle.layer.shadowOffset = imageViewLogo.layer.shadowOffset

        //Facebook
        self.facebookInit()
        
        //Google Init
        self.googleInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //---------------------------------------------------------------------
    //MARK: - Terms of Service

    @IBAction func onTermsOfService(_ sender: UIButton) {
        
        let messageText = NSMutableAttributedString(
            string: "By logging in to Textor, you agree not to:\n\n- use our service to send spam or scam users.\n- promote violence.\n- post pornographic content.\n\nWe reserve the right to update these Terms of Service later.",
            attributes: [
                NSParagraphStyleAttributeName: NSParagraphStyle.default,
                NSFontAttributeName : UIFont.systemFont(ofSize: 12),
                NSForegroundColorAttributeName : UIColor.darkGray
            ]
        )
        
        let alertController = UIAlertController(title: "Terms of Service", message: "", preferredStyle: .alert)
        
        alertController.setValue(messageText, forKey: "attributedMessage")
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //---------------------------------------------------------------------
    //MARK: - Orientation

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.tileImageView.configureFrames()
    }
    
    //---------------------------------------------------------------------
    //MARK: - Universal Login

    func proccessLogin(_ loginType:LoginType, email:String, firstName:String, lastName:String, imageURL:String?) {
        
        func logoutClean(banned:Bool) {
            GCD.mainThread {
                self.hideSpinner()
            }
            if banned {
                User.logout(banned: true, { (completed) in
                })
                //Banned
                self.alert("Sorry", title: "You were banned")
            } else {
                User.logout({ (completed) in
                })
                //Connection problem
                self.alert("Connection Problem", title: "Could not connect to socket")
            }
        }
        
        User.loginUniversal(loginType, email: email, firstName: firstName, lastName: lastName, imageURL: imageURL,  completion: { (success, banned) in
            
            if success == true && banned == false {
                
                DataManager.needLoginTransition = true
                InitialVC.connectListenSocket()
                
            } else if success == true && banned == true {
                //Banned
                logoutClean(banned: true)
            } else {
                //Connection problem
                logoutClean(banned: false)
            }
        })
    }
    
    
}

