//
//  StatusHistory.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/6/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import Foundation
import RealmSwift

class StatusHistory: Object {
    
    let message = LinkingObjects(fromType: Message.self, property: "statusHistory")
    
    dynamic var id = ""
    dynamic var readerId = ""
    dynamic var timestampDelivered:Int = 0
    dynamic var timestampSeen:Int = 0
    
    convenience init(data:[String:AnyObject]) {
        self.init()
        self.id = (data["_id"] as? String ?? "").trim()
        self.readerId = (data["readerId"] as? String ?? "").trim()
        self.timestampDelivered = data["timestampDelivered"] as? Int ?? 0
        self.timestampSeen = data["timestampSeen"] as? Int ?? 0
    }
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override var debugDescription: String {
        return "<\nreaderId:\(self.readerId) \ntimestampDelivered:\(self.timestampDelivered) \ntimestampSeen:\(self.timestampSeen)\n>"
    }
}
