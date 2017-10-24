//
//  ChattoChatVC+Socketable.swift
//  Textor
//
//  Created by eugene golovanov on 3/23/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions
import RealmSwift

protocol Socketable {
    func messageReceived(creationId : String)
    func updateBackButton()
    func outcomeMessageSeen(creationId : String, data:[String:AnyObject])
    func outcomeMessageDelivered(creationId: String, data:[String:AnyObject])
}

/**
 This extension is made for connection existing ChattoChatVC to SocketIOManager with delegation
 */
extension ChattoChatVC : Socketable {
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: - Message Received

    func messageReceived(creationId: String) {
        if self.isDisplaying {
            print("---------ID:\(creationId)---------")
            self.dataSource.messageReceived(uid: creationId)
            self.updateBackButton()
        }
    }
    
    func updateBackButton() {
        GCD.mainThread {
            self.backButtonDelegate?.backButton(badge: self.updateBackButtonBadge())
        }
    }
    
    func outcomeMessageSeen(creationId: String, data:[String:AnyObject]) {
        print("---------Sended Message Seen:\(creationId)---------")
        self.dataSource.outcomeMessageSeen(UID: creationId, data: data)
    }
    
    func outcomeMessageDelivered(creationId: String, data:[String:AnyObject]) {
        print("---------Sended Message Delivered:\(creationId)---------")
        self.dataSource.outcomeMessageDelivered(UID: creationId, data: data)
    }

}
