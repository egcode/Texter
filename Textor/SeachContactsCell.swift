//
//  SeachContactsCell.swift
//  Textor
//
//  Created by eugene golovanov on 2/10/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class SeachContactsCell: UITableViewCell {
    
    @IBOutlet weak var pieLoaderAvatar: PieImageLoader!
    @IBOutlet weak var labelFullname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(contact:Contact) {
        self.labelFullname.text = contact.fullName
        pieLoaderAvatar.getImageWithUrl(avatarUrl: contact.avatarUrl)
    }

}
