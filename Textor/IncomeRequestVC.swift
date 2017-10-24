//
//  IncomeRequestVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/21/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class IncomeRequestVC: UIViewController {
    
    var contact:Contact? = nil
    
    @IBOutlet weak var tileImage: TileImageAnimated!
    @IBOutlet weak var avatarPieImageLoader: PieImageLoader!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var avatarImage: RoundedUIImageView!
    @IBOutlet weak var buttonAccept: UIButton!
    @IBOutlet weak var buttonReject: UIButton!
    @IBOutlet weak var buttonBlock: UIButton!
    //--------------------------------------------------------------------------------------------------
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Image from cache
        if let cont = self.contact, let img = DataManager.imageCache.object(forKey: cont.avatarUrl as NSString) {
            self.avatarPieImageLoader.image = img
        }

        guard let cont = self.contact else {magic("problem with contact");return}
        self.labelName.text = cont.fullName
        self.emailLabel.text = cont.email
        
        //Shadow
        let shadowColor = UIColor.black.cgColor
        let shadowRadius: CGFloat = 5
        let shadowOpacity: Float = 0.6
        let shadowOffset = CGSize(width: 0, height: 4)
        labelName.layer.shadowColor = shadowColor
        labelName.layer.shadowRadius = shadowRadius
        labelName.layer.shadowOpacity = shadowOpacity
        labelName.layer.shadowOffset = shadowOffset
        buttonAccept.layer.shadowColor = shadowColor
        buttonAccept.layer.shadowRadius = shadowRadius
        buttonAccept.layer.shadowOpacity = shadowOpacity
        buttonAccept.layer.shadowOffset = shadowOffset
        buttonReject.layer.shadowColor = shadowColor
        buttonReject.layer.shadowRadius = shadowRadius
        buttonReject.layer.shadowOpacity = shadowOpacity
        buttonReject.layer.shadowOffset = shadowOffset
        buttonBlock.layer.shadowColor = shadowColor
        buttonBlock.layer.shadowRadius = shadowRadius
        buttonBlock.layer.shadowOpacity = shadowOpacity
        buttonBlock.layer.shadowOffset = shadowOffset

        //Corners
        buttonAccept.layer.cornerRadius = 4
        buttonReject.layer.cornerRadius = 4
        buttonBlock.layer.cornerRadius = 4
    }
    //---------------------------------------------------------------------
    //MARK: - Orientation
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //swift 3
        self.tileImage.configureFrames()
    }

    //----------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func onAcceptButton(_ sender: UIButton) {
        magic("On Accept")
        self.operateIncomeRequest(makefriend: true)
    }
    
    @IBAction func onRejectButton(_ sender: UIButton) {
        magic("On Reject")
        self.operateIncomeRequest(makefriend: false)
    }
    
    @IBAction func onBlockButton(_ sender: UIButton) {
        magic("On Block")
        self.blockContactPrompt()
    }
    
    //----------------------------------------------------------------------
    // MARK: - Block

    private func blockContactPrompt() {
        let alert = UIAlertController(title: "Are you sure?", message: "This contact will be blocked, you can ublock it later", preferredStyle: .actionSheet)
        
        // delete chatroom
        let deleteAction = UIAlertAction(title: "Block", style: .destructive) { (action: UIAlertAction) -> Void in
            self.proccessBlockContact()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Main Method that blocks contact and rejects it
     */
    private func proccessBlockContact() {
        guard let cont = self.contact else { magic("contact error"); return }
        
        SocketIOManager.sharedInstance.blockContact(cont.id) { (blockedContactId) in
            print(" -Blocked Id Send: \(cont.id) \n -Blocked Received:\(blockedContactId)")
            if cont.id == blockedContactId {
                self.operateIncomeRequest(makefriend: false)
            }
        }
    }

    //----------------------------------------------------------------------
    // MARK: - Income request Operate

    func operateIncomeRequest(makefriend:Bool) {
        
        guard let token = DataManager.model.currentUser?.token else {magic("token problem");return}
        guard let contact = self.contact else {magic("contact problem");return}
        
        let url = URL_API + "/requestin/" + "\(contact.id)"
        
        let paramsDictionary = ["makefriend": makefriend, "email": contact.email] as [String : Any]
        
        ///////////////////
        API.put(url as AnyObject, payload: paramsDictionary as [String : AnyObject], userToken: token, completed: { (response) in
            print("==============")
            print(response)
            print("==============")

            GCD.mainThread( block: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshRequests"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshContactsFromServer"), object: nil)
                
                self.navigationController?.popToRoot(animated: true)

                if response.code == 200 && response.success == true {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatroomsFromServer"), object: nil)
                    self.alert("Created New Friend", title: "SUCCESS")
                } else if response.code == 204 {
//                    self.alert("Rejected", title: "Successfully")
                    print("\nRejected Successfully\n")
                } else if response.code == 500 {
                    self.alert("server error 500")
                }
                //refresh IncomeRequestsTVC
                if response.code == 200 || response.code == 204 {
                    NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "removeOperatedRequests"), object: nil, userInfo: ["id" : contact.id]))
                }
            })
        })
        ///////////////////////
    }
}
