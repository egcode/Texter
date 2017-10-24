//
//  Message.swift
//  Textor
//
//  Created by eugene golovanov on 8/26/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import RealmSwift
//import Chatto
//import ChattoAdditions

public enum MessageType: String {
    case text = "text"
    case photo = "photo"
    case emoji = "emoji"
}

class Message: Object {
    
    //-------------------------------------------------------------------------------------------------
    // MARK: - Properties

    let chatroom = LinkingObjects(fromType: Chatroom.self, property: "messages")
    let user = LinkingObjects(fromType: User.self, property: "messages")

    //db
    dynamic var id: String = ""
    dynamic var creationId = ""
    dynamic var text:String = ""
    dynamic var senderEmail:String = ""
    dynamic var senderId:String = ""
    dynamic var timestamp:Int = 0
    dynamic var chatroomId:String = ""
    dynamic var statusDB:String = ""
    var statusHistory = List<StatusHistory>()

    //Chatto
    dynamic var date = Date(timeIntervalSince1970: 0)
    dynamic var type: String = ""
    
    //Photo
    dynamic var photoData:Data?
    dynamic var photoUrl:String = ""
    dynamic var photoSize:String = ""
    
    //Helper
    var isOutgoing: Bool {
        if self.senderId == DataManager.model.currentUser?.id {
            return true
        }
        return false
    }
    //------------------------------------------------------------------------------------------------------
    // MARK: - Init
    
    /**
     Refresh statusHistory from data, Method should be invoked in write block
     */
    func refreshStatusHistory(data:[String:AnyObject]) {
        if let statusHistoryDataArray = data["statusHistory"] as? [[String:AnyObject]] {
            guard let u = DataManager.model.currentUser else  { magic("no user"); return }
            
            for statusData in statusHistoryDataArray {
                let id = (statusData["_id"] as? String ?? "").trim()

                //if not exists
                if self.statusHistory.contains( where: { $0.id == id } ) == false {
                    let sh = StatusHistory(data: statusData)
                    self.statusHistory.append(sh)
                } else {
                //if already exists
                    if let existingSH = u.getRealm().object(ofType: StatusHistory.self, forPrimaryKey: id) {
                        existingSH.timestampDelivered = statusData["timestampDelivered"] as? Int ?? 0
                        existingSH.timestampSeen = statusData["timestampSeen"] as? Int ?? 0
                    }
                }
                
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshStatusHistory"), object: nil)
        }

    }
    
    //Init from db
    convenience init(data:[String:AnyObject]) {
        self.init()
        self.id  = (data["_id"] as? String ?? "").trim()
        self.creationId = (data["creationId"] as? String ?? UUID().uuidString).trim()
        self.text = (data["text"] as? String ?? "").trim()
        self.senderEmail = (data["senderEmail"] as? String ?? "").trim()
        self.timestamp = data["timestamp"] as? Int ?? 0
        self.senderId = (data["senderId"] as? String ?? "").trim()
        self.chatroomId = (data["chatroomId"] as? String ?? "").trim()
        self.statusDB = (data["status"] as? String ?? "").trim()
        
        //Chatto
        self.date = DateHelpers.dateFromTimestamp(timestamp: self.timestamp)
        self.type = (data["type"] as? String ?? "").trim()
        
        ///Photo\\\
        self.photoUrl = (data["photoUrl"] as? String ?? "").trim()
        self.photoSize = (data["photoSize"] as? String ?? "").trim()

        if let image = data["photoData"] as? UIImage, let imageData = Message.convertUIImageToData(image: image) {
            if self.type == MessageType.photo.rawValue {
                self.photoData = imageData
            }
        }
        
        //StatusHistory
        self.refreshStatusHistory(data: data)
    }
    
    //-----------------------------------------------------------------------------------------------
    // MARK: - Helpers

    override class func primaryKey() -> String? {
        return "creationId"
    }
    
    class func convertUIImageToData(image:UIImage) -> Data? {
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            return imageData
        }
       return nil
    }
    
   override var debugDescription: String {
        return "<\nid:\(self.id) \ncreationId:\(self.creationId) \ntext: \(self.text), \nsenderEmail:\(self.senderEmail), \nsenderId:\(self.senderId), \ntimestamp:\(self.timestamp) \nchatroomId:\(self.chatroomId) \nstatus:\(self.statusDB)\nphotoUrl:\(self.photoUrl)\ndate:\(self.date)\nstatusHistory:\(self.statusHistory)\n>"
    }
}
