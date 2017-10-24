//
//  MessageDataSource.swift
//  Textor
//
//  Created by eugene golovanov on 9/28/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions
import RealmSwift
import Alamofire
import ImageIO


class TXMessageDataSource: ChatDataSourceProtocol {
    
    var user:User?
    var chatroom:Chatroom?
    let slidingDS: SlidingDataSource
    
    init(chatroom:Chatroom) {
        self.slidingDS = SlidingDataSource(chatroom: chatroom)
        self.delegate?.chatDataSourceDidUpdate(self)
    }
    
    lazy var messageSender: TXMessageSender = {
        let sender = TXMessageSender()
        sender.user = self.user
        sender.chatroom = self.chatroom
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()
    
    
    var hasMoreNext: Bool {
        return false
    }
    func loadNext() {
//        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }

    var hasMorePrevious: Bool {
        guard let firstMess = self.slidingDS.messages.first else {
            //If no messages in chat
            print("Chatroom Is empty, no previous messages in both backend and frontend")
            return false
        }
        //If we already have some messages in realm
        if let chr = self.chatroom,
            let firstRealmMessage = chatroom?.getRealm().object(ofType: Message.self, forPrimaryKey: firstMess.uid) {
            
            if chr.firstMessageUID == firstMess.uid {
                return false
            } else {
                return self.slidingDS.checkForMoreInRealm(chatroom: chr, firstRealmMessage: firstRealmMessage)
            }
            
        } else {
            return false
        }
    }
    
    func loadPrevious() {
        if let chr = self.chatroom,
            let firstRealmMessage = chatroom?.getRealm().object(ofType: Message.self, forPrimaryKey: self.slidingDS.messages.first?.uid) {
           self.slidingDS.getMorePageMessagesFromRealm(chatroom: chr, firstRealmMessage: firstRealmMessage)
        }
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .pagination)
    }

    
    var chatItems: [ChatItemProtocol] {
        return self.slidingDS.messages
    }
    
    weak var delegate: ChatDataSourceDelegateProtocol?

    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:((Bool)) -> Void) {
        completion(false)
    }
    
    
    //-------------------------------------------------------------------------------------------------
    // MARK: - Sending messages

    func sendTextMessage(_ text: String) {
        
        self.refreshSeparator()
        
        guard let user = self.user else {magic("no user");return}
        
        let textMessage = ChattorHelpers.createTextMessageModel(uid: UUID().uuidString, text: text, senderId: user.id, isIncoming: false, date: Date(), statusExtended: .sending, allowUnseenSeparator: false)
        self.messageSender.sendTextMessage(textMessage, text: text)
        self.slidingDS.messages.append(textMessage)
        self.delegate?.chatDataSourceDidUpdate(self)
        
    }
    
    func sendPhotoMessage(_ image: UIImage) {
        
        self.refreshSeparator()
        
        guard let user = self.user else {magic("no user");return}
        
        let photoMessage = ChattorHelpers.createPhotoMessageModel(UUID().uuidString, image: image, senderId: user.id, size: image.size, isIncoming: false, date: Date(), statusExtended: .sending, allowUnseenSeparator: false)
        self.messageSender.sendPhotoMessage(photoMessage, image: image)
        self.slidingDS.messages.append(photoMessage)
        self.delegate?.chatDataSourceDidUpdate(self)
    }

    
    //-------------------------------------------------------------------------------------------------
    // MARK: - Incoming Message Received

    
    func messageReceived(uid:String) {
        guard let message = self.chatroom?.getRealm().object(ofType: Message.self, forPrimaryKey: uid) else {
            magic("no received message in Realm");return}
        if message.chatroomId == self.chatroom?.id {
            let chattoMessage = ChattorHelpers.convertRealmToChattoMessage(realmMessage: message, allowUnseenSeparator: false)
            
            self.slidingDS.messages.append(chattoMessage)
            self.delegate?.chatDataSourceDidUpdate(self)
            
            if chattoMessage.type == MessageType.photo.rawValue {
                //If received message is image, donwload it
                self.downloadImageAndSave(chattoMessage as! TXPhotoMessageModel)
                
            } else if chattoMessage.type == MessageType.text.rawValue {
               self.incomeMessageMakeSeenWithUID(UID: chattoMessage.uid)
            }
        }
    }
    
    //-------------------------------------------------------------------------------------------------
    // MARK: - Download image and save to Data
    
    func downloadAllImages() {
        for m in self.slidingDS.messages {
            if m.type == "photo" {
                if OperationsManager.sharedOM.downloadsInProgress[m.uid] != nil {
                    break
                }
                self.downloadImageAndSave(m as! TXPhotoMessageModel)
            }
        }
    }
    

    
    
    func downloadImageAndSave(_ message: TXPhotoMessageModel) {

        if let urlString = message.imageUrl {
            
            message.statusExtended = .getting
            RefreshManager.sharedRM.updateMessage(message)
            
            ///// Downloader \\\\\
            let downloader = ImageDownloader(message: message, url: urlString) { responseObject, image, error in
                
                guard let downloadedImage = image else {
                    message.statusExtended = .failed
                    RefreshManager.sharedRM.updateMessage(message)
                    OperationsManager.sharedOM.downloadsInProgress[message.uid] = nil
                    return
                }
                
                //  .success instead of .seen beacause we need to see Separator
                // it will dissapear if we .seen
                var finalStatus = EGMessageStatus.success
                if !message.isIncoming {
                    finalStatus = ChattorHelpers.getStatusFromRealm(UID: message.uid)
                }
                let photoMessage = ChattorHelpers.createPhotoMessageModel(message.uid, image: downloadedImage, senderId: message.senderId, size: downloadedImage.size, isIncoming: message.isIncoming, date: message.date, statusExtended: finalStatus, allowUnseenSeparator: message.allowUnseenSeparator)
                    self.saveDownloadedImageToRealm(photoMessage) // SAVE To Realm
                RefreshManager.sharedRM.updateMessage(photoMessage)

                if message.isIncoming && self.messageSender.chattoVC?.isDisplaying == true{
                        self.incomeMessageMakeSeenWithUID(UID: message.uid) // Make Seen if incoming
                }
                OperationsManager.sharedOM.downloadsInProgress[message.uid] = nil
            }
            ///// End of Downloader \\\\\
            
            OperationsManager.sharedOM.downloadsInProgress[message.uid] = downloader
            OperationsManager.sharedOM.downloadQueue.addOperation(downloader)
        }
    }
    
    func saveDownloadedImageToRealm(_ message: TXPhotoMessageModel) {
        if let imageData = Message.convertUIImageToData(image: message.image) {
            let editMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: message.uid as AnyObject)
            DataManager.model.currentUser?.write({
                editMessage?.photoData = imageData
            })
        }
    }
    
    //-------------------------------------------------------------------------------------------------
    // MARK: - Make messages Seen
    
    /**
    Receiver:
    ---1 send to server to update socket.emit("messageSeen"
    ---2 update in realm from server's Ack
    -server-3 update in mongoDB
    -server-4 send ack to receiver that it is seen --- For updating in realm
    
    Sender:
    -server-5 send socket.emit("messageSeen"  to sender
    ---6 update message status in sender from socket.on("messageSeen" - with 'outcomeMessageSeen'
    */
    
    
///////////////////////  INCOME  ///////////////////
    // MARK: Income Messages
    
    /**
     Make all income messages seen
     */
    func incomeAllMessagesMakeSeen() {
        
        guard let user = DataManager.model.currentUser else {magic("no current user");return}
        guard let chatroom = self.chatroom else {magic("no chatroom");return}

        //Get All Messages From REALM
        let chatroomPredicate = NSPredicate(format: "chatroomId = %@", chatroom.id)
        let realmMessagesArray = chatroom.getRealm().objects(Message.self).filter(chatroomPredicate).sorted(byProperty: "timestamp",ascending: true)
        
        for message in realmMessagesArray {
            //if message is Incoming and not Seen
            if message.senderId != user.id && message.statusDB != MESSAGE_STATUS_SEEN {
                if message.type == MessageType.text.rawValue {
                    //Immediately we make seen only text messages
                    self.incomeMessageMakeSeenWithUID(UID: message.creationId)
                } else if message.type == MessageType.photo.rawValue {
                    if message.photoData != nil {
                        self.incomeMessageMakeSeenWithUID(UID: message.creationId)
                    }
                }
            }
        }
    }
    
    
    func incomeMessageMakeSeenWithUID(UID:String) {
        
        guard let chatroom = self.chatroom else { magic("no chatroom"); return }
        guard let readerId = DataManager.model.currentUser?.id else { magic("no reader Id"); return }
        let timestampSeen = DateHelpers.timestampFromDate(date: Date())
        
        //find in realm
        guard let incomeMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: UID) else {
            magic("no edit message")
            return
        }
        //////////////////////////
        //+++---1 send to server to update socket.emit("messageSeen"
        SocketIOManager.sharedInstance.reportMessageSeen(incomeMessage.id, readerId:readerId, timestampSeen:timestampSeen) { (messageDict) in

            print("---------------------- Message Made SEEN on server: ----------------------")
            print(messageDict)
            print("-----------------------------------------------------------")
            
            let id = messageDict["_id"] as? String
            if incomeMessage.id == id {//Just in case verify than we updated same id on server
         
        //////////////////////////
        //+++---2 update in realm
                DataManager.model.currentUser?.write({
                    incomeMessage.statusDB = MESSAGE_STATUS_SEEN
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatrooms"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBadge"), object: nil)
                })

            }
            
        }
        
    }

///////////////////////  OUTCOME  ///////////////////
    // MARK: Outcome Messages

    func outcomeMessageSeen(UID:String, data:[String:AnyObject]) {

        //update in realm
        let outcomeMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: UID)
        DataManager.model.currentUser?.write({
            outcomeMessage?.statusDB = MESSAGE_STATUS_SEEN
            outcomeMessage?.refreshStatusHistory(data: data)
        })
        
        ///-Refresh cell Status to SEEN
        self.updateMessageStatusWithID(with: UID, status: .seen)
    }
    
    func outcomeMessageDelivered(UID:String, data:[String:AnyObject]) {
        
        //update in realm
        let outcomeMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: UID)
        DataManager.model.currentUser?.write({
            outcomeMessage?.statusDB = MESSAGE_STATUS_DELIVERED
            outcomeMessage?.refreshStatusHistory(data: data)
        })
        
        ///-Refresh cell Status to DELIVERED
        self.updateMessageStatusWithID(with: UID, status: .delivered)
    }

    /**
     If someone will change status while user offline we won't update it
     */
    func checkOutcomeMessagesStatus() {
        
        guard let chatroom = self.chatroom else {magic("no chatroom");return}
        
        //Get All Messages From REALM
        let chatroomPredicate = NSPredicate(format: "chatroomId = %@", chatroom.id)
        let realmMessagesArray = chatroom.getRealm().objects(Message.self).filter(chatroomPredicate).sorted(byProperty: "timestamp",ascending: true)

        
        for message in realmMessagesArray {
            if message.statusDB == MESSAGE_STATUS_SENT || message.statusDB == MESSAGE_STATUS_DELIVERED {
                
                SocketIOManager.sharedInstance.checkStatusForMessage(message.id) { [weak self] (messageDataToUpdate) in
                    
                    let messageToUpdate = Message(data: messageDataToUpdate)
                    print(messageToUpdate)
                    
                    guard let editMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: messageToUpdate.creationId) else {magic("no edit message");return}
                    
                    //compare status Mongo vs Realm
                    if messageToUpdate.statusDB != editMessage.statusDB {
                        DataManager.model.currentUser?.write({
                            editMessage.statusDB = messageToUpdate.statusDB
                            editMessage.refreshStatusHistory(data: messageDataToUpdate)
                        })
                        
                        let s:EGMessageStatus = editMessage.statusDB == MESSAGE_STATUS_SEEN ? .seen : .delivered
                        
                        ///-Refresh cell Status to SEEN
                        self?.updateMessageStatusWithID(with: editMessage.creationId, status: s)
                    }
                }
                
            }
        }
        
    }
    
    //-------------------------------------------------------------------------------------------------
    // MARK: - update status helpers

    private func updateMessageStatusWithID(with id: String, status: EGMessageStatus) {
        if let mess = self.slidingDS.messages.filter({ $0.uid == id}).first {
            self.updateMessageStatus(mess as! TXMessageModelProtocol, statusExtended: status)
        }
    }
    
    private func updateMessageStatus(_ message: TXMessageModelProtocol, statusExtended: EGMessageStatus) {
        if message.statusExtended != statusExtended {
            message.statusExtended = statusExtended
            self.delegate?.chatDataSourceDidUpdate(self)
        }
    }
    
    //-------------------------------------------------------------------------------------------------
    // MARK: - Helpers

    private func refreshSeparator() {
        for message in self.slidingDS.messages {
            if let m = message as? TXMessageModelProtocol {
                if m.allowUnseenSeparator == true {
                    self.updateMessageStatus(m, statusExtended: ChattorHelpers.getStatusFromRealm(UID: m.uid))
                }
            }
        }
    }
    
    func deleteMessageFromChatto(_ message: TXMessageModelProtocol, toDeleteFromRealm:Bool) {
        for (index, mess) in self.slidingDS.messages.enumerated() {
            if mess.uid == message.uid {
                self.slidingDS.messages.remove(at: index)
                if toDeleteFromRealm { self.deleteMessageFromRealm(message.uid) }
                self.delegate?.chatDataSourceDidUpdate(self)
            }
        }
    }
    
    func deleteMessageFromRealm(_ uid: String) {
        guard let messageRealm = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: uid) else {
            magic("no message to delete in realm")
            return
        }
        DataManager.model.currentUser?.write({
            DataManager.model.currentUser?.getRealm().delete(messageRealm)
        })
    }
    
}

