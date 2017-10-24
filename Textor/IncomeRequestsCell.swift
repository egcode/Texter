//
//  IncomeRequestsCell.swift
//  Textor
//
//  Created by eugene golovanov on 2/13/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class IncomeRequestsCell: UITableViewCell {

    @IBOutlet weak var pieLoaderAvatar: PieImageLoader!
    @IBOutlet weak var labelEmail: UILabel!
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
        self.labelEmail.text = contact.email
        pieLoaderAvatar.getImageWithUrl(avatarUrl: contact.avatarUrl)
    }

}
