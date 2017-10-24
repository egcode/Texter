//
//  SocketIOManager.swift
//  Textor
//
//  Created by eugene golovanov on 8/14/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import SocketIO
import Foundation

class SocketIOManager: NSObject {
    
    //----------------------------------------------------------------------------------------
    //MARK: - Properties
    
    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: URL_API)! as URL)
    weak var chattoDelegate: ChattoChatVC?

    //----------------------------------------------------------------------------------------
    //MARK: - Init
    
    override init() {
        super.init()
    }
    
    //----------------------------------------------------------------------------------------
    //MARK: - Connection
    
    func startSocketConnection(_ completion: @escaping (_ connected: Bool) -> Void) {
        self.addHandlers()
        
        self.socket.on("connect") {data, ack in
            magic("socket connected")
            completion(true) //this completion we run every time when we reconnect
        }

        self.socket.connect(timeoutAfter: 2) {
            completion(false)
        }

    }
    
    func stopSocketConnection() {
        self.socket.disconnect()
        self.socket.removeAllHandlers()
    }
    
    func getContacts(_ email: String, id: String, completion: @escaping (_ contactsData: [[String: AnyObject]]) -> Void) {
        
        self.socket.emit("connectUser", email, id)
        
        self.socket.once("userList") { ( dataArray, ack) -> Void in
            guard let data = dataArray.first as? [[String: AnyObject]] else {
                magic("no list")
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "alert"), object: nil, userInfo: ["alertTitle" : "User list error", "alertMessage":"Failed to get get friends from server"]))
                return
            }
            completion(data)
        }
    }
    
    func checkConnection(_ completion: (_ connected: Bool) -> Void) {
        if socket.status != SocketIOClientStatus.connected {
            completion(false)
        } else {
            completion(true)
        }
    }
    
    
    //----------------------------------------------------------------------------------------
    //MARK: - Handlers

    func addHandlers() {
        guard let user = DataManager.model.currentUser else {magic("no current user");return}
        
        self.socket.on("banned") {data in
            User.logout( { (completed) in
            })
            InitialVC.showLogin()
        }
        self.socket.on("error") {data in
            magic("bliat socket ERROR")
            magic(data)
            
            //Throwing right message
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                magic("Something wrong with delegate")
                return
            }
            if appDelegate.reachability?.isReachable == true  {
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: BarType.showConnecting.rawValue), object: nil, userInfo: ["type" : CONNECTING_MSG_CONNECTING]))
            } else {
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: BarType.showConnecting.rawValue), object: nil, userInfo: ["type" : CONNECTING_MSG_WAITING_NET]))
            }
            //Set all contacts offline
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setAllContactsOffline"), object: nil)
        }
        self.socket.on("chatroomList") { ( dataArray, ack) -> Void in
            guard let chatroomList = dataArray.first as? [[String: AnyObject]] else {magic("no chatrooms");return}
            for chatroom in chatroomList {
                let id  = (chatroom["_id"] as? String ?? "").trim()
                if user.chatrooms.contains( where: { $0.id == id } ) == false {
                    
                    let chrm = Chatroom(data: chatroom)
                    user.write({
                        user.chatrooms.append(chrm)
                    })
                    
                    SocketIOManager.sharedInstance.fetchMessagesPageForChatroom(chatroom: chrm, user: user)

                } else {
                    print("chatroom already cached")
                }
            }
        }
        self.socket.on("newIncomingMessages") { ( dataArray, ack) -> Void in
            guard let newIncomingMessages = dataArray.first as? [[String: AnyObject]] else {magic("messages error");return}
            for message in newIncomingMessages {
                let mess = Message(data: message)
                print(mess)
                
                if let chatroom = DataManager.model.currentUser?.getRealm().object(ofType: Chatroom.self, forPrimaryKey: mess.chatroomId) {
                    DataManager.model.currentUser?.write({
                        chatroom.isHidden = false
                        
                        if chatroom.messages.contains( where: { $0.creationId == mess.creationId } ) == false {
                            chatroom.messages.append(mess)
                            user.messages.append(mess)
                        }
                        self.messageRefreshProcedure(creationId: mess.creationId, chatroom: chatroom)
                        
                    })
                }
            }
        }
        self.socket.on("message") { (dataArray, socketAck) -> Void in
            guard let data = dataArray.first as? [String : AnyObject] else {magic("something wrong with message data");return}
            let message = Message(data: data)
            let chatroom = DataManager.model.currentUser?.getRealm().object(ofType: Chatroom.self, forPrimaryKey: message.chatroomId)
            
            if chatroom?.messages.contains( where: { $0.creationId == message.creationId } ) == false {
                DataManager.model.currentUser?.write({
                    chatroom?.messages.append(message)
                    chatroom?.isHidden = false
                    user.messages.append(message)
                })
                self.messageRefreshProcedure(creationId: message.creationId, chatroom: chatroom)
                
            } else {
                magic("Received Object already written")
            }
        }
        self.socket.on("messageSeen") { (dataArray, socketAck) -> Void in
            guard let data = dataArray.first as? [String : AnyObject] else {magic("something wrong with message data");return}
            let message = Message(data: data)
            if let chattoVC = SocketIOManager.sharedInstance.chattoDelegate {
                //update both db and chatto
                chattoVC.outcomeMessageSeen(creationId: message.creationId, data: data)
            } else {
                //update db
                DataManager.model.currentUser?.write({
                    let outcomeMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: message.creationId)
                    outcomeMessage?.statusDB = MESSAGE_STATUS_SEEN
                    outcomeMessage?.refreshStatusHistory(data: data)
                })
            }
        }
        self.socket.on("messageDelivered") { (dataArray, socketAck) -> Void in
            guard let data = dataArray.first as? [String : AnyObject] else {magic("something wrong with message data");return}
            let message = Message(data: data)
            
            if let chattoVC = SocketIOManager.sharedInstance.chattoDelegate {
                //update both db and chatto
                chattoVC.outcomeMessageDelivered(creationId: message.creationId, data: data)
            } else {
                //update db only
                DataManager.model.currentUser?.write({
                    let outcomeMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: message.creationId)
                    outcomeMessage?.statusDB = MESSAGE_STATUS_DELIVERED
                    outcomeMessage?.refreshStatusHistory(data: data)
                })
            }
        }
        self.socket.on("typing") { ( dataArray, ack) -> Void in
            
            guard let chatroomId = dataArray.first as? String else { magic("no typing chatroomId"); return }
            guard let userId = dataArray.last as? String else { magic("no typing userId"); return }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "typingReceived"), object: chatroomId)
            if let chattoVC = SocketIOManager.sharedInstance.chattoDelegate {
                if chattoVC.dataSource.chatroom?.id == chatroomId {
                    if let c = user.getRealm().object(ofType: Contact.self, forPrimaryKey: userId) {
                        chattoVC.typingReceived(contact: c)
                    }
                }
            }
        }
        self.socket.on("status") {data in
            if let userFromJS = data.0.first as? [String:AnyObject] {
                if let id = userFromJS["id"] as? String,
                    let isOnline = userFromJS["isOnline"] as? Bool {
                    
                    guard let contact = DataManager.model.currentUser?.getRealm().object(ofType: Contact.self, forPrimaryKey: id) else { magic("no contact to update"); return }
                    DataManager.model.currentUser?.write({
                        contact.isOnline = isOnline
                        if let timestamp = userFromJS["timestampLastOnline"] as? Int {
                            contact.dateLastOnline = DateHelpers.dateFromTimestamp(timestamp: timestamp)
                        }
                    })
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "statusChanged"), object: contact)
                    
                    //Update status in ChattoVC if it not nil
                    if let chattoVC = SocketIOManager.sharedInstance.chattoDelegate, let ids = chattoVC.dataSource.chatroom?.oppositeContactIds {
                        for id in ids  {
                            if id.contactId == contact.id {
                                //"BarType.showDefaultBar" - also updates contact status in chatto vc
                                NotificationCenter.default.post(name: Notification.Name(rawValue: BarType.showDefault.rawValue), object: nil)
                            }
                        }
                    }
                    
                    
                }

            }
        }
        socket.on("request") { (userData, socketAck) -> Void in
            guard let requestor = userData.first as? [String:String] else {magic("user exit fail");return}
            guard let firstName = requestor["firstName"] else {magic("no requestor firstName");return}
            guard let lastName = requestor["lastName"] else {magic("no requestor lastName");return}

            let fullName = "\(firstName) \(lastName)"
            let alertTitle = "New friend request"
            let alertMessage = "\(fullName) wants to be your friend"
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "alert"), object: nil, userInfo: ["alertTitle" : alertTitle, "alertMessage":alertMessage]))
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshRequests"), object: nil)
        }

        socket.on("requestAccepted") { (requestUser, socketAck) -> Void in
            guard let requestor = requestUser.first as? [String:String] else {magic("user exit fail");return}

            guard let firstName = requestor["firstName"] else {magic("no requestor firstName");return}
            guard let lastName = requestor["lastName"] else {magic("no requestor lastName");return}
            
            let fullName = "\(firstName) \(lastName)"
            let alertTitle = "You have a new friend"
            let alertMessage = "\(fullName) accepted your friend request"
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "alert"), object: nil, userInfo: ["alertTitle" : alertTitle, "alertMessage":alertMessage]))

            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshContactsFromServer"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatroomsFromServer"), object: nil)

        }
        self.socket.on("deleteFriend") { (dataArray, socketAck) -> Void in
            guard let deleterUserData = dataArray.first as? [String : String] else {magic("Delete Contact problem");return}
            if let deleterUserId = deleterUserData["id"] {
                NotificationCenter.default.post(name: Notification.Name(rawValue:"friendDeleted"), object: nil, userInfo: ["friendToDeleteId":deleterUserId])
            }
        }

        
    }
    
    //MARK: Handler Helpers
    
    private func messageRefreshProcedure(creationId:String, chatroom:Chatroom?) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatrooms"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBadge"), object: nil)
        
        func makeDelivered(creationId:String) {
            //Received and DELIVERED
            if let message = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: creationId) {
                
                guard let readerId = DataManager.model.currentUser?.id else { magic("no reader Id"); return }
                let timestampDelivered = DateHelpers.timestampFromDate(date: Date())

                //1 send to server to update socket.emit("messageDelivered"
                SocketIOManager.sharedInstance.reportMessageDelivered(message.id, readerId:readerId, timestampDelivered:timestampDelivered) { (messageDict) in
                    let id = messageDict["_id"] as? String
                    if message.id == id {//Just in case verify that we updated same id on server
                        DataManager.model.currentUser?.write({
                            message.statusDB = MESSAGE_STATUS_DELIVERED
                        })
                    }
                }
            }
        }
        
        if let chattoVC = SocketIOManager.sharedInstance.chattoDelegate {
            if chattoVC.dataSource.chatroom?.id == chatroom?.id {
                //If we see right chatto, the one the message belongs to
                chattoVC.messageReceived(creationId: creationId)
            } else {
                //If we see chatto not the one that message came
                chattoVC.updateBackButton()
                makeDelivered(creationId: creationId)
            }
        } else {
            makeDelivered(creationId: creationId)
        }

    }

    //----------------------------------------------------------------------------------------
    //MARK: - Contacts

    func deleteContact(_ contactId:String,_ chatroomId:String, contactCallback: @escaping (_ deletedContactDict: [String:AnyObject]) -> Void) {
        self.socket.emitWithAck("deleteFriend", ["contactId": contactId, "chatroomId" : chatroomId]).timingOut(after: 0) {data in
            guard let userDeleted = data.first as? [String: AnyObject] else {magic("no deleted User");return}
            contactCallback(userDeleted)
        }
    }
    
    func blockContact(_ contactId:String, contactCallback: @escaping (_ blockedContactId: String) -> Void) {
        self.socket.emitWithAck("blockFriend", ["contactId": contactId]).timingOut(after: 0) {data in
            guard let userBlockedId = data.first as? String else { magic("no blocked User Id");return }
            contactCallback(userBlockedId)
        }
    }
    
    func unblockContact(_ contactId:String, contactCallback: @escaping (_ blockedContactId: String) -> Void) {
        self.socket.emitWithAck("unblockFriend", ["contactId": contactId]).timingOut(after: 0) {data in
            guard let userBlockedId = data.first as? String else { magic("no unblocked User Id");return }
            contactCallback(userBlockedId)
        }
    }
    
    func getAllBlockedContacts(contactCallback: @escaping (_ blockedContactsDict: [[String:AnyObject]]) -> Void) {
        self.socket.emitWithAck("allBlocked", ["_":"_"]).timingOut(after: 0) {data in
            guard let usersBlocked = data.first as? [[String: AnyObject]] else { magic("no blocked Contacts");return }
            contactCallback(usersBlocked)
        }
    }

    //----------------------------------------------------------------------------------------
    //MARK: - Chatrooms
    
    func chatroomsGetAndReconnect(_ userId:String, chatroomsCallback: @escaping (_ chatroomsArr: [[String:AnyObject]]) -> Void) {
        self.socket.emitWithAck("chatroomsGetAndReconnect", ["userId": userId]).timingOut(after: 0) {data in
            guard let chatrooms = data.first as? [[String: AnyObject]] else {magic("no deleted User");return}
            chatroomsCallback(chatrooms)
        }
    }
    
    func fetchMessagesPageForChatroom(chatroom:Chatroom, user:User) {
        //Fetch first Page Messages for Chatroom
        SocketIOManager.sharedInstance.fetchChatroomPageFromTimestamp(chatroom, timestamp: DateHelpers.timestampFromDate(date: Date()), user: user, pageSize: SlidingDataSource.PAGE_SIZE, messageCallback: { (pageMessages) in
            print("\n*********Fetched first page of messages for chatroom: \(chatroom.title)******\n")
        })
    }
    
    //----------------------------------------------------------------------------------------
    //MARK: - Typing

    func sendTypingMade(_ chatroomId:String, userId:String) {
        self.socket.emit("typing", chatroomId, userId)
    }

    //----------------------------------------------------------------------------------------
    //MARK: - Messages
    
    func sendMessage(_ type: String, messageText:String, messagePhoto:String, messageSize:String, creationId:String, senderEmail:String, senderId: String, timestamp:Int, chatroomId: String, messageCallback: @escaping (_ messageDict: [String:AnyObject]) -> Void) {
        
        //Task works in 2 seconds if we have no response from ack
        let task = DispatchWorkItem {
            messageCallback([:])
        }
        // execute task in 2 seconds
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: task)
        
        //Payload
        var messagePayload = ["creationId": creationId,
                              "senderEmail": senderEmail,
                              "senderId": senderId,
                              "timestamp": timestamp,
                              "chatroomId": chatroomId,
                              "type": type] as [String : Any]
        
        switch type {
        case MessageType.text.rawValue:
            messagePayload["text"] = messageText
        case MessageType.photo.rawValue:
            messagePayload["photoUrl"] = messagePhoto
            messagePayload["photoSize"] = messageSize

        default:
            break
        }
        
        //Send Message to server
        self.socket.emitWithAck("message", messagePayload).timingOut(after: 0) {data in
            
            guard let msg = data.first as? [String: AnyObject] else {
                magic("no message")
                messageCallback([:])
                return
            }
            // cancel task
            task.cancel()
            
            messageCallback(msg)
        }

    }
    
    /**
     Method reports that message made seen on server, and now we can make it seen in realm
     */
    func reportMessageSeen(_ messageIdForMongo:String, readerId:String, timestampSeen:Int, messageCallback: @escaping (_ messageDict: [String:AnyObject]) -> Void) {
        self.socket.emitWithAck("messageSeen", ["messageId": messageIdForMongo, "readerId":readerId, "timestampSeen": timestampSeen]).timingOut(after: 0) {data in
            guard let msg = data.first as? [String: AnyObject] else {magic("no seen mess");return}
            messageCallback(msg)
        }
    }
    /**
     Method reports that message made delivered on server, and now we can make it delivered in realm
     */
    func reportMessageDelivered(_ messageIdForMongo:String, readerId:String, timestampDelivered:Int, messageCallback: @escaping (_ messageDict: [String:AnyObject]) -> Void) {
        self.socket.emitWithAck("messageDelivered", ["messageId": messageIdForMongo, "readerId":readerId, "timestampDelivered": timestampDelivered]).timingOut(after: 0) {data in
            guard let msg = data.first as? [String: AnyObject] else {magic("no delivered mess");return}
            messageCallback(msg)
        }
    }

    
    
    func checkStatusForMessage(_ messageId: String , messageCallback: @escaping (_ messageDict: [String:AnyObject]) -> Void) {
        self.socket.emitWithAck("messageStatusCheck", ["messageId": messageId]).timingOut(after: 0) {data in
            
            guard let message = data.first as? [String: AnyObject] else {magic("no seen mess");return}
            messageCallback(message)
        }
    }
    
    func fetchAllMessages(_ user: User, userId: String , messageCallback: @escaping (_ messageDict: [[String:AnyObject]]) -> Void) {
        self.socket.emitWithAck("allMessagesFetch", ["usrId": userId]).timingOut(after: 0) {data in
            
            guard let allMessages = data.first as? [[String: AnyObject]] else {magic("no All messages");return}
            for message in allMessages {
                
                let mess = Message(data: message)
                let chatroom = DataManager.model.currentUser?.getRealm().object(ofType: Chatroom.self, forPrimaryKey: mess.chatroomId)
                
                if chatroom?.messages.contains( where: { $0.creationId == mess.creationId } ) == false {
                    DataManager.model.currentUser?.write({
                        chatroom?.messages.append(mess)
                        user.messages.append(mess)
                        chatroom?.isHidden = false
                    })
                }

            }
            messageCallback(allMessages)
        }
    }
    
    /**
     Fetch page messages for specific chatroom and from specific timestamp.
     If timestamp is now time we load first page for chatroom
     */
    func fetchChatroomPageFromTimestamp(_ chatroom:Chatroom, timestamp:Int, user:User, pageSize:Int, messageCallback: @escaping (_ messageDict: [[String:AnyObject]]) -> Void) {
        self.socket.emitWithAck("messagesPageFromTimestamp", ["usrId" : user.id,
                                                              "pageSize" : pageSize,
                                                              "timestamp" : timestamp,
                                                              "chatroomId" : chatroom.id]).timingOut(after: 0) {data in
            guard let morePageMessages = data.first as? [[String: AnyObject]] else {magic("no first page messages");return}
            for message in morePageMessages {
                
                let mess = Message(data: message)
                if chatroom.messages.contains( where: { $0.creationId == mess.creationId } ) == false {
                    user.write({
                        chatroom.messages.append(mess)
                        user.messages.append(mess)
                        chatroom.isHidden = false
                    })
                }
            }
            messageCallback(morePageMessages)
        }
    }
}
