//
//  Contact.swift
//  Textor
//
//  Created by eugene golovanov on 8/11/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import RealmSwift

//class Contact: CustomStringConvertible {
class Contact: Object {
    
    dynamic var id = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var email = ""
    dynamic var isOnline = false
    dynamic var avatarUrl = ""
    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }
    dynamic var dateLastOnline:Date?
    
    convenience init(data: [String: AnyObject]) {
        self.init()
        self.id  = (data["id"] as? String ?? "").trim()
        self.email  = (data["email"] as? String ?? "").trim()
        self.firstName  = (data["firstName"] as? String ?? "").trim()
        self.lastName  = (data["lastName"] as? String ?? "").trim()
        self.avatarUrl  = (data["avatarUrl"] as? String ?? "").trim()

        if let isonline = data["isOnline"] as? Bool{
            self.isOnline = isonline
        }
        if let timestamp = data["timestampLastOnline"] as? Int {
            self.dateLastOnline = DateHelpers.dateFromTimestamp(timestamp: timestamp)
        }
    }
    
   override var description: String {
        return "<\nid=\(self.id) \nfullName=\(self.fullName) \nemail=\(self.email) \nfirstName=\(self.firstName) \nlastName=\(self.lastName) \navatarUrl=\(self.avatarUrl)\nstatus=\(self.isOnline)\ndateLastOnline=\(self.dateLastOnline)\n>"
    }

    override class func primaryKey() -> String? {
        return "id"
    }

}
