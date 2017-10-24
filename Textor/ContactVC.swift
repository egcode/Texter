//
//  ContactVC.swift
//  Textor
//
//  Created by Eugene Golovanov on 6/6/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class ContactVC: UITableViewController {
    
    @IBOutlet weak var imageViewAvatar: RoundedUIImageView!
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    @IBOutlet weak var labelStatus: UILabel!
    
    var avatarImage:UIImage? = nil
    
    var contact:Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let c = self.contact {
            self.labelFullName.text = c.fullName
            self.labelEmail.text = c.email
            self.updateLabelStatus(contact: c)
        }
        
        if let avIm = self.avatarImage {
            self.imageViewAvatar.image = avIm
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.contact?.isInvalidated == true {
            InitialVC.showMain() // if we blocked user we go straight to main
        }
    }
    
    //--------------------------------------------------------------------
    //MARK: - init deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactVC.setContactOffline), name: NSNotification.Name(rawValue: "setAllContactsOffline"), object: nil)
        
        //User Status changed
        NotificationCenter.default.addObserver(self, selector: #selector(ContactVC.contactStatusChanged(_:)), name: NSNotification.Name(rawValue: "statusChanged"), object: nil)
        
        
        //Contact Deleted on server
        NotificationCenter.default.addObserver(self, selector: #selector(ContactVC.deleteContactFromSocket(_:)), name: NSNotification.Name(rawValue: "friendDeleted"), object: nil)
    }
    
    deinit {
        print("\nContactVC deinited")
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------------------------------------------------------------------
    // MARK: - Helpers
    
    func updateLabelStatus(contact:Contact) {
        self.labelStatus.text = contact.isOnline ? "Online" : "Offline"
        self.labelStatus.textColor = contact.isOnline ? UIColor.green : UIColor.lightGray
        
        if !contact.isOnline && contact.dateLastOnline != nil {
            if let date = contact.dateLastOnline {
                let lastSeenDate = DateHelpers.dateStringFromDate(date: date)
                let timeSeenDate = DateHelpers.timeStringFromDate(date: date)
                self.labelStatus.text = "last seen \(lastSeenDate) at \(timeSeenDate)"
            }
        }
    }
    
    //--------------------------------------------------------------------------------------------------
    // MARK: - Notifications methods

    func contactStatusChanged(_ notification: Notification) {
        guard let updContact = notification.object as? Contact else { magic("problem with upd contact"); return }
        guard let cont = self.contact else { magic("contact error"); return }
        if cont.id == updContact.id {
            self.updateLabelStatus(contact: cont)
        }
    }
    
    func setContactOffline() {
        self.labelStatus.text = "Offline"
        self.labelStatus.textColor = UIColor.lightGray
    }

    func deleteContactFromSocket(_ notification: Notification) {
        //Go straight to Contacts, because if we navigate back to chat that doesn't exist we crash
        if self.contact?.isInvalidated == true {
            InitialVC.showMain()
        }
    }
    
    //--------------------------------------------------------------------------------------------------
    // MARK: - Block Contact
    
    @IBAction func onBlockButton(_ sender: UIButton) {
        self.blockContactPrompt()
    }
    
    private func blockContactPrompt() {
        let alert = UIAlertController(title: "Are you sure?", message: "This contact will be blocked and deleted and all messages with this contact will be deleted! You can unblock and reconnect later.", preferredStyle: .actionSheet)
        
        // delete chatroom
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction) -> Void in
            self.proccessBlockContact()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Main Method that blocks contact and deletes it with all messages and chatrooms
     */
    private func proccessBlockContact() {
        guard let cont = self.contact else { magic("contact error"); return }
        
        SocketIOManager.sharedInstance.blockContact(cont.id) { (blockedContactId) in
            print(" -Blocked Id Send: \(cont.id) \n -Blocked Received:\(blockedContactId)")
            if cont.id == blockedContactId {
                NotificationCenter.default.post(name: Notification.Name(rawValue:"friendBlocked"), object: nil, userInfo: ["friendToBlockedId":blockedContactId])
                InitialVC.showMain() // if we blocked user we go straight to main
            }
        }
    }

}
