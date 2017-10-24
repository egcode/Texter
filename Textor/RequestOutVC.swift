//
//  RequestOutVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/18/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class RequestOutVC: UIViewController {
    
    var contact:Contact? = nil

    @IBOutlet weak var avatarPieImageView: PieImageLoader!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var tileImageView: TileImageAnimated!
    
    //---------------------------------------------------------------------
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Image from cache
        if let c = self.contact {
            if let img = DataManager.imageCache.object(forKey: c.avatarUrl as NSString) {
                self.avatarPieImageView.image = img
            }
        }

        guard let cont = self.contact else {magic("problem with contact");return}
        self.labelName.text = cont.fullName
        
        //Shadow
        let shadowColor = UIColor.black.cgColor
        let shadowRadius: CGFloat = 5
        let shadowOpacity: Float = 0.6
        let shadowOffset = CGSize(width: 0, height: 4)
        self.labelName.layer.shadowColor = shadowColor
        self.labelName.layer.shadowRadius = shadowRadius
        self.labelName.layer.shadowOpacity = shadowOpacity
        self.labelName.layer.shadowOffset = shadowOffset
        self.requestButton.layer.shadowColor = shadowColor
        self.requestButton.layer.shadowRadius = shadowRadius
        self.requestButton.layer.shadowOpacity = shadowOpacity
        self.requestButton.layer.shadowOffset = shadowOffset
        //Corners
        self.requestButton.layer.cornerRadius = 4
    }
    
    //---------------------------------------------------------------------
    // MARK: - Orientation
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //swift 3
        self.tileImageView.configureFrames()
    }


    @IBAction func onRequestButton(_ sender: AnyObject) {
        
        guard let token = DataManager.model.currentUser?.token else {magic("token problem");return}
        guard let contact = self.contact else {magic("contact problem");return}
        
        let url = URL_API + "/requestout/" + "\(contact.id)"
        
        API.post(url as AnyObject, userToken: token) { (response) in
            GCD.mainThread(block: {
                if response.code == 200 && response.success == true {
                    self.alert("Contact Request Successfully sent", title: "SUCCESS")
                } else if response.code == 201 {
                    self.alert("You are in the list of blocked contacts of this user", title: "Sorry")
                } else if response.code == 202 {
                    self.alert("Check your income requests, this user is already whants to connect with you", title: "Caution")
                } else if response.code == 204 {
                    self.alert("Request is already sent", title: "Maybe you forgot")
                } else if response.code == 500 {
                    self.alert("server error 500")
                }
            })
        }
    }
    
    

}
