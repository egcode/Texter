//
//  ContactsCell.swift
//  Textor
//
//  Created by eugene golovanov on 1/22/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Alamofire

class ContactsCell: UITableViewCell {
    
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var viewAvatar: PieImageLoader!
    @IBOutlet weak var labelLastSeen: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.labelLastSeen.alpha = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(contact: Contact) {
        
        self.labelFullName.text = contact.fullName
        self.labelEmail.text = contact.email
        
        self.labelStatus.text = contact.isOnline ? "Online" : "Offline"
        self.labelStatus.textColor = contact.isOnline ? UIColor.green : UIColor.red
        
        //Image from cache
        if let img = DataManager.imageCache.object(forKey: contact.avatarUrl as NSString) {
            self.viewAvatar.image = img
        } else {
            self.viewAvatar.getImageWithUrl(avatarUrl: contact.avatarUrl)
        }
        
        //Last seen label
        self.labelLastSeen.alpha = contact.isOnline ? 0 : 1.0
        if !contact.isOnline && contact.dateLastOnline != nil {
            if let date = contact.dateLastOnline {
                let lastSeenDate = DateHelpers.dateStringFromDate(date: date)
                let timeSeenDate = DateHelpers.timeStringFromDate(date: date)
                self.labelLastSeen.text = "last seen \(lastSeenDate) at \(timeSeenDate)"
            }
        }

    }

}
