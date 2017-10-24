//
//  StatusHistoryCell.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/8/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class StatusHistoryCell: UITableViewCell {

    @IBOutlet weak var pieImageAvatar: PieImageLoader!
    @IBOutlet weak var labelFullname: UILabel!
    
    @IBOutlet weak var labelDeliveredDate: UILabel!
    @IBOutlet weak var labelDeliveredTime: UILabel!
    
    @IBOutlet weak var labelReadDate: UILabel!
    @IBOutlet weak var labelReadTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func configureCell(contact:Contact, statusHistory:StatusHistory) {
        
        //Delivered
        if statusHistory.timestampDelivered == 0 {
            self.labelDeliveredDate.text = ""
            self.labelDeliveredTime.text = "----"
        } else {
            let dateDelivered = DateHelpers.dateFromTimestamp(timestamp: statusHistory.timestampDelivered)
            self.labelDeliveredDate.text = DateHelpers.dateStringFromDate(date: dateDelivered)
            self.labelDeliveredTime.text = DateHelpers.timeStringFromDate(date: dateDelivered)
        }
        
        //Seen
        if statusHistory.timestampSeen == 0 {
            self.labelReadDate.text = ""
            self.labelReadTime.text = "----"
        } else {
            let dateSeen = DateHelpers.dateFromTimestamp(timestamp: statusHistory.timestampSeen)
            self.labelReadDate.text = DateHelpers.dateStringFromDate(date: dateSeen)
            self.labelReadTime.text = DateHelpers.timeStringFromDate(date: dateSeen)
        }
        
        //Image from cache
        if let img = DataManager.imageCache.object(forKey: contact.avatarUrl as NSString) {
            self.pieImageAvatar.image = img
        } else {
            self.pieImageAvatar.getImageWithUrl(avatarUrl: contact.avatarUrl)
        }

        self.labelFullname.text = contact.fullName
    }
    
    

}
