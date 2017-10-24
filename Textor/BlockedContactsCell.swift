//
//  BlockedContactsCell.swift
//  Textor
//
//  Created by Eugene Golovanov on 6/10/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

protocol UnblockContactsDelegate {
    func unblockContact(contact: Contact)
}

class BlockedContactsCell: UITableViewCell {

    @IBOutlet weak var avatarPieImage: PieImageLoader!
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var buttonUnblock: UIButton!
    
    var delegate: UnblockContactsDelegate?
    var contact: Contact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Shadow
        self.buttonUnblock.layer.shadowColor = UIColor.black.cgColor
        self.buttonUnblock.layer.shadowRadius = 5
        self.buttonUnblock.layer.shadowOpacity = 0.6
        self.buttonUnblock.layer.shadowOffset = CGSize(width: 0, height: 4)
        //Corners
        self.buttonUnblock.layer.cornerRadius = 4
    }

    @IBAction func onUnblockAction(_ sender: UIButton) {
        print("Unblock button tapped")
        guard let c = self.contact else { magic("no contact"); return }
        delegate?.unblockContact(contact: c)
    }
    
    func configureCell(contact: Contact) {
        self.contact = contact
        self.labelFullName.text = contact.fullName
        self.labelEmail.text = contact.email
        
        //Image from cache
        if let img = DataManager.imageCache.object(forKey: contact.avatarUrl as NSString) {
            self.avatarPieImage.image = img
        } else {
            self.avatarPieImage.getImageWithUrl(avatarUrl: contact.avatarUrl)
        }
    }
}
