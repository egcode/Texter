//
//  AccountVC.swift
//  Textor
//
//  Created by eugene golovanov on 1/18/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class AccountVC: UITableViewController {
    
    @IBOutlet weak var imageViewAvatar: RoundedUIImageView!
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    @IBOutlet weak var labelLoginType: UILabel!
    @IBOutlet weak var imageViewLoginType: UIImageView!
    
    var avatarImage:UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageViewLoginType.clipsToBounds = true
        self.imageViewLoginType.layer.cornerRadius = 4
        
        if let avIm = self.avatarImage {
            self.imageViewAvatar.image = avIm
        }
        if let fn = DataManager.model.currentUser?.fullName {self.labelFullName.text = fn}
        if let e = DataManager.model.currentUser?.email {self.labelEmail.text = e}
        
        if let lt = DataManager.model.currentUser?.loginType {
            self.labelLoginType.text = "Logged in with \(lt)"
            if lt == LoginType.google.rawValue {
                self.imageViewLoginType.image = UIImage(named: LoginType.google.rawValue)
            } else if lt == LoginType.facebook.rawValue {
                self.imageViewLoginType.image = UIImage(named: LoginType.facebook.rawValue)
            }
        }
    }
        
    //---------------------------------------------------------------------
    // MARK: - Actions
    
    @IBAction func onReportButton(_ sender: UIButton) {
        sendEmail()
    }
    @IBAction func onBlockedContacts(_ sender: UIButton) {
        self.performSegue(withIdentifier: "blockedContactsSegue", sender: nil)
    }

    @IBAction func onLogoutButton(_ sender: UIButton) {
        User.logout { (success) in
            if success {
                InitialVC.showLogin()
            } else {
                GCD.mainThread(block: { self.alert("Logout Failed", title: "Failed")})
            }
        }
    }
}

