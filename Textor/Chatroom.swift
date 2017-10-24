//
//  Chatroom.swift
//  Textor
//
//  Created by eugene golovanov on 8/30/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import RealmSwift

class RealmString: Object {
    dynamic var contactId = ""
}

class Chatroom: Object {
    
    let user = LinkingObjects(fromType: User.self, property: "chatrooms")
    
    dynamic var id = ""
    dynamic var title = ""
    dynamic var isCustom = false
    dynamic var isHidden = false
    
    dynamic var firstMessageUID:String? //We can recieve this value if we scrolled to the last message
    
    var badge: Int {
        //predicate - if oppositeContactIds containts contactId that is equal to selectedContact.id, and if chatroom is not custom
//        let predicate = NSPredicate(format: "ANY messages.statusDB ==[c] %@ AND ANY messages.isOutgoing ==[c] %@ ", MESSAGE_STATUS_SENT, false as CVarArg)
//        let unreadMessages = self.getRealm().objects(Message.self).filter(predicate)
//        return unreadMessages.count
        var b:Int = 0
        for message in self.messages {
            if message.statusDB == MESSAGE_STATUS_SENT || message.statusDB == MESSAGE_STATUS_DELIVERED {
                if message.isOutgoing == false {
                    b += 1
                }
            }
        }
        return b
    }


    let oppositeContactIds = List<RealmString>()
    let messages = List<Message>()
    
    var lastMessage: Message? {
        let chatroomPredicate = NSPredicate(format: "chatroomId = %@", self.id)
        let lastMessage = self.getRealm().objects(Message.self).filter(chatroomPredicate).sorted(byProperty: "timestamp",ascending: true).last
        return lastMessage
    }
    
    var date: Date {
        if let dt = self.lastMessage?.date {
            return dt
        }
        return Date.init(timeIntervalSince1970: 0)
    }

    convenience init(data: [String: AnyObject]) {
        self.init()
        
        self.id  = (data["_id"] as? String ?? "").trim()
        self.title  = (data["title"] as? String ?? "").trim()
        self.isCustom  = data["custom"] as? Bool ?? false
        self.isHidden  = data["hidden"] as? Bool ?? false

        //Getting OppositeContacts
        guard let curUsrId = DataManager.model.currentUser?.id else {magic("no cur id");return}
        let allIds = data["users"] as? Array<String> ?? []
        if !allIds.isEmpty {
            let opIds = allIds.filter({ (opId) -> Bool in
                return opId != curUsrId
            })
            for oid in opIds {
                
                if self.oppositeContactIds.contains(where: {$0.contactId == oid}) == false {
                    let str = RealmString()
                    str.contactId = oid
                    self.oppositeContactIds.append(str)
                } else {
                    print("Contact Id Already Exists")
                }
            }
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    

}
