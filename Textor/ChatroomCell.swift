//
//  ChatroomCell.swift
//  Textor
//
//  Created by eugene golovanov on 8/31/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class ChatroomCell: UITableViewCell {
    
    @IBOutlet weak var badgeView: ChatroomBadgeView!
    @IBOutlet weak var pieImageAvatar: PieImageLoader!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var typingLabel: UILabel!
    
    var chatroomId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool,animated: Bool) {
        let color = self.badgeView.backgroundColor
        super.setSelected(selected, animated: animated)
        if(selected) {
            self.badgeView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool,animated: Bool) {
        let color = self.badgeView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if(highlighted) {
            self.badgeView.backgroundColor = color
        }
    }
    
    func configureWithChatroom(_ chatroom:Chatroom) {
        
        //Typing
        self.chatroomId = chatroom.id
        
        //Last Message
        if chatroom.lastMessage?.type == MessageType.text.rawValue {
            if let decodedText = chatroom.lastMessage?.text.base64Decoded() {
                self.labelMessage.text = decodedText
            } else {
                self.labelMessage.text = ""
            }
        } else if chatroom.lastMessage?.type == MessageType.photo.rawValue {
            self.labelMessage.text = "Photo Message"
        }

        //Name
        guard let opCont = ChattorHelpers.getOppositeContactsFromChatroom(chatroom) else  {magic("no opposite contacts");return}
        //FOR NOW JUST ONLY ONE CONTACT
        guard let contact = opCont.first else {magic("no opposite contact");return}
        self.labelName.text = contact.fullName
        
        //Date
        if chatroom.lastMessage != nil {
            labelDate.text = DateHelpers.dateStringFromDate(date: chatroom.date)
        } else {
            labelDate.alpha = 0
            self.labelMessage.text = "\(contact.fullName) joined Textor"
        }
        
        //Image from cache
        if let img = DataManager.imageCache.object(forKey: contact.avatarUrl as NSString) {
            self.pieImageAvatar.image = img
        } else {
            self.pieImageAvatar.getImageWithUrl(avatarUrl: contact.avatarUrl)
        }
        
        //Badge
        self.badgeView.value = chatroom.badge
    
    }
    
    //------------------------------------------------------------------------------
    // MARK: - Typing UI
    
    func setTyping(isTyping:Bool) {
        GCD.mainThread {
            if isTyping == true {
                self.labelMessage.alpha = 0
                self.typingLabel.alpha = 1
            } else {
                self.labelMessage.alpha = 1
                self.typingLabel.alpha = 0
            }
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: - Typing Received

    var timerTypeIn:Timer?
    var countTypingIn:Int = TYPING_RECEIVE_WAIT

    func typingReceived() {
        GCD.mainThread {
            if self.timerTypeIn == nil {
                self.timerTypeIn = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ChatroomCell.timerTypingIn), userInfo: nil, repeats: true)
                self.setTyping(isTyping: true)
            } else {
                self.countTypingIn = TYPING_RECEIVE_WAIT
            }
        }
    }
    
    func timerTypingIn(timer:Timer) {
        self.countTypingIn -= 1
        print("Typing in Chatroom:\(String(describing: self.chatroomId)) IN COUNTER: \(countTypingIn)")
        
        if self.countTypingIn <= 0 {
            self.timerTypeIn?.invalidate()
            self.timerTypeIn = nil
            self.countTypingIn = TYPING_RECEIVE_WAIT
            self.setTyping(isTyping: false)
        }
    }


}
