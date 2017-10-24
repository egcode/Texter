//
//  User.swift
//  Textor
//
//  Created by eugene golovanov on 8/9/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import RealmSwift

enum LoginType: String {
    case none = "none"
    case google = "google"
    case facebook = "facebook"
}

class User: Object {
    dynamic var id = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var email = ""
    dynamic var token = ""
    dynamic var loginType = LoginType.none.rawValue
    dynamic var avatarUrl:String?
    
    var fullName: String {
        return "\(self.firstName) \(self.lastName)"
    }

    let contacts = List<Contact>()
    let chatrooms = List<Chatroom>()
    let messages = List<Message>()

    convenience init(id:String, email:String, firstName:String, lastName:String, token:String, loginType: String = LoginType.none.rawValue) {
        self.init()
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.token = token
        self.loginType = loginType
    }
        
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override var debugDescription: String {
        return "<\nid=\(self.id); \nfirstName=\(self.firstName); \nlastName=\(self.lastName); \nemail=\(self.email); \nloginType=\(self.loginType); \ncontactsCount=\(self.contacts.count) \nchatrooms=\(self.chatrooms.count) \nmessages=\(self.messages.count) \ntoken=\(self.token) \navatarUrl=\(self.avatarUrl)\n>"
    }

}

