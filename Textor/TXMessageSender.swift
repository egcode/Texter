//
//  MessageSender.swift
//  Textor
//
//  Created by eugene golovanov on 9/28/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions
import Alamofire
import SwiftyJSON

public protocol TXMessageModelProtocol: EGMessageModelProtocol {
    var statusExtended: EGMessageStatus { get set }
    var progress:Double?  { get set }
}

public class TXMessageSender {
    
    var user:User?
    var chatroom:Chatroom?
    weak var chattoVC: ChattoChatVC?
    
    public var onMessageChanged: ((_ message: TXMessageModelProtocol) -> Void)?
    
    //----------------------------------------------------------------------
    // MARK: - Send Photo Message

    public func sendPhotoMessage(_ message: TXPhotoMessageModel, image: UIImage) {
        
        
        guard let user = self.user else {magic("no user");return}
        guard let chatroom = self.chatroom else {magic("no chatroom");return}
        let timestamp = DateHelpers.timestampFromDate(date: message.date)
        
        var messageDictionary = [String: AnyObject]()
        messageDictionary["photoData"] = image as AnyObject?
        messageDictionary["photoSize"] = NSStringFromCGSize(image.size) as AnyObject?
        messageDictionary["senderEmail"] = user.email as AnyObject?
        messageDictionary["senderId"] = user.id as AnyObject?
        messageDictionary["timestamp"] = timestamp as AnyObject?
        messageDictionary["chatroomId"] = chatroom.id as AnyObject?
        messageDictionary["status"] = MESSAGE_STATUS_SENDING as AnyObject?
        messageDictionary["creationId"] = message.uid as AnyObject?
        messageDictionary["type"] = MessageType.photo.rawValue as AnyObject?
        
        
        ////// CREATE Message and Save To REALM as 'not sent'
        let messageRealm = Message(data: messageDictionary)
        if messageRealm.chatroomId == chatroom.id {
            if chatroom.messages.contains( where: { $0.creationId == messageRealm.creationId } ) == false {
                DataManager.model.currentUser?.write({
                    chatroom.messages.append(messageRealm)
                    user.messages.append(messageRealm)
                })
            } else {
                magic("Object already written")
            }
            
        }
        ///// End of CREATE

        message.statusExtended = .sending
        RefreshManager.sharedRM.updateMessage(message)
        
        ///// Uploader \\\\\
        let uploader = self.createPhotoUploader(message, messageRealm: messageRealm, chatroomId: chatroom.id)
        OperationsManager.sharedOM.uploadsInProgress[message.uid] = uploader
        OperationsManager.sharedOM.uploadQueue.addOperation(uploader)
    }
    
    //----------------------------------------------------------------------
    // MARK: - Send Text Message
    
    public func sendTextMessage(_ message: TXMessageModelProtocol, text: String) {
        
        guard let user = self.user else {magic("no user");return}
        guard let chatroom = self.chatroom else {magic("no chatroom");return}
        guard let encodedText = text.base64Encoded() else {magic("no encoded text");return}
        let timestamp = DateHelpers.timestampFromDate(date: message.date)

        var messageDictionary = [String: AnyObject]()
        messageDictionary["text"] = encodedText as AnyObject?
        messageDictionary["senderEmail"] = user.email as AnyObject?
        messageDictionary["senderId"] = user.id as AnyObject?
        messageDictionary["timestamp"] = timestamp as AnyObject?
        messageDictionary["chatroomId"] = chatroom.id as AnyObject?
        messageDictionary["status"] = MESSAGE_STATUS_SENDING as AnyObject?
        messageDictionary["creationId"] = message.uid as AnyObject?
        messageDictionary["type"] = MessageType.text.rawValue as AnyObject?

        
        ////// CREATE Message and Save To REALM as 'not sent'
        let messageRealm = Message(data: messageDictionary)
        if messageRealm.chatroomId == chatroom.id {
            if chatroom.messages.contains( where: { $0.creationId == messageRealm.creationId } ) == false {
                DataManager.model.currentUser?.write({
                    chatroom.messages.append(messageRealm)
                    user.messages.append(messageRealm)
                })
            } else {
                magic("Object already written")
            }

        }
        ///// End of CREATE
        ///// ------------- Send Message To SERVER -----------------
        self.sendMessageToServer(message, messageRealm: messageRealm, timestamp: timestamp)
    }
    
    //----------------------------------------------------------------------
    // MARK: - Long Press handlers

    func longPressBubblePrompt(_ message: TXMessageModelProtocol) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // delete failed message
        if !message.isIncoming {
            let infoAction = UIAlertAction(title: "Info", style: .default) { (action: UIAlertAction) -> Void in
                if let realmMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: message.uid) {
                    self.chattoVC?.performSegue(withIdentifier: Segue.statusHistory.rawValue, sender: realmMessage)
                } else {
                    magic("no realm message")
                }
            }
            alert.addAction(infoAction)
        }
        
        // delete failed message
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction) -> Void in
            print("delete tapped")
            self.chattoVC?.dataSource.deleteMessageFromChatto(message, toDeleteFromRealm: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // if long press text message adding copy action
        if let m = message as? TXTextMessageModel {
            // copy text message
            let copyAction = UIAlertAction(title: "Copy Text", style: .default) { (action: UIAlertAction) -> Void in
                print("copy text tapped")
                UIPasteboard.general.string = m.text
            }
            alert.addAction(copyAction)
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let vc = self.chattoVC {
            GCD.mainThread {
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }

    //----------------------------------------------------------------------
    // MARK: - Helpers
    
    private func sendMessageToServer(_ message: TXMessageModelProtocol, messageRealm: Message, timestamp:Int) {
        
        guard let chatroom = self.chatroom else {magic("no chatroom");return}
        
        ///// ------------- Send Message To SERVER -----------------
        SocketIOManager.sharedInstance.sendMessage(messageRealm.type, messageText: messageRealm.text, messagePhoto: messageRealm.photoUrl, messageSize: messageRealm.photoSize, creationId: messageRealm.creationId, senderEmail: messageRealm.senderEmail , senderId: messageRealm.senderId, timestamp: timestamp, chatroomId: chatroom.id, messageCallback: { [weak self] (messageDict) in
            
            print("================= ACK: =======================")
            print(messageDict)
            print("==============================================")
            
            //IF FAILED
            if messageDict.isEmpty  {
                DataManager.model.currentUser?.write({
                    messageRealm.statusDB = MESSAGE_STATUS_NOT_SENT
                })
                message.statusExtended = .failed
                RefreshManager.sharedRM.updateMessage(message)
                return
            }
            
            ///// UPDATE message in REALM from Server callback and make it 'sent'
            let ackMessage = Message(data: messageDict)
            if ackMessage.chatroomId == chatroom.id {
                
                guard let editMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: ackMessage.creationId as AnyObject) else {
                    magic("no local realm messae")
                    return
                }

                DataManager.model.currentUser?.write({
                    editMessage.id = ackMessage.id
                    if editMessage.statusDB != MESSAGE_STATUS_SEEN {
                        editMessage.statusDB = ackMessage.statusDB
                    }
                    chatroom.isHidden = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatrooms"), object: nil)
                })

                //Make status seen in chatVC if it's already seen in realm db
                //It could happen if 'made seen' faster than 'send message ack'
                //Else just update status to 'sent'
                if  editMessage.statusDB == MESSAGE_STATUS_SEEN {
                    message.statusExtended = .seen
                } else {
                    message.statusExtended = .success
                }
                RefreshManager.sharedRM.updateMessage(message)
            }
            ////// End of UPDATE
            
        })
        
    }

   private func createPhotoUploader(_ message: TXPhotoMessageModel, messageRealm: Message, chatroomId: String) -> ImageUploader {
        
        return ImageUploader(message: message, messageRealm: messageRealm, chatroomId: chatroomId, imageToUpload: message.image) { message, success in
            
            if success {
                // SUCCESS
                RefreshManager.sharedRM.updateMessage(message)
                OperationsManager.sharedOM.uploadsInProgress[message.uid] = nil
                
                ///// ------------- Send Photo Message To SERVER -----------------
                self.sendMessageToServer(message, messageRealm: messageRealm, timestamp: messageRealm.timestamp)
            } else {
                
                // FAILED
                magic("Timer Upload FAIL")
                message.statusExtended = .failed
                message.progress = 0
                RefreshManager.sharedRM.updateMessage(message)
                OperationsManager.sharedOM.uploadsInProgress[message.uid] = nil
                
                DataManager.model.currentUser?.write({
                    messageRealm.statusDB = MESSAGE_STATUS_NOT_SENT
                })
                
            }
        }
    }
    
    //----------------------------------------------------------------------
    // MARK: - Photo was tapped

    func photoTapped(_ message: TXMessageModelProtocol) {
        let photoMessage = message as! TXPhotoMessageModel
        self.chattoVC?.photoTapped(image: photoMessage.image)
    }
    
    //----------------------------------------------------------------------
    // MARK: - Failed messages prompt
    
    /**
     Red circle prompt
     */
    func failedMessagePrompt(_ message: TXMessageModelProtocol) {
                
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // delete failed message
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction) -> Void in
            print("delete tapped")
            self.chattoVC?.dataSource.deleteMessageFromChatto(message, toDeleteFromRealm: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if !message.isIncoming {
            // resend failed message
            let resendAction = UIAlertAction(title: "Resend", style: .default) { (action: UIAlertAction) -> Void in
                print("resend tapped")
                self.resendMessage(message)
            }
            alert.addAction(resendAction)
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let vc = self.chattoVC {
            GCD.mainThread {
                vc.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    /**
     Resending photo from tapping on red circle
     */
    func resendMessage(_ message: TXMessageModelProtocol) {
        guard let chatroom = self.chatroom else {magic("no chatroom");return}
        guard let messageRealm = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: message.uid) else {
            magic("no resend message in realm")
            return
        }
        DataManager.model.currentUser?.write({
            messageRealm.date = Date()
            messageRealm.timestamp = Int(messageRealm.date.timeIntervalSince1970 * 1000)
            messageRealm.statusDB = MESSAGE_STATUS_SENDING
        })
        
        /////--Delete from chatto and send
        if let chatto = self.chattoVC {
            //Delete
            chatto.dataSource.deleteMessageFromChatto(message, toDeleteFromRealm: false)
            
            //--Photo message
            if let photoMessage = message as? TXPhotoMessageModel {
                let photMess = ChattorHelpers.createPhotoMessageModel(messageRealm.creationId, image: photoMessage.image, senderId: photoMessage.senderId, size: photoMessage.image.size, isIncoming: false, date: messageRealm.date, statusExtended: .sending, allowUnseenSeparator: false)
                chatto.dataSource.slidingDS.messages.append(photMess)
                chatto.dataSource.delegate?.chatDataSourceDidUpdate(chatto.dataSource)
                
                //Refresh
                RefreshManager.sharedRM.updateMessage(photMess)
                
                ///// Uploader \\\\\
                let uploader = self.createPhotoUploader(photMess, messageRealm: messageRealm, chatroomId: chatroom.id)
                OperationsManager.sharedOM.uploadsInProgress[photoMessage.uid] = uploader
                OperationsManager.sharedOM.uploadQueue.addOperation(uploader)
            }
            //--Text message
            if let textMessage = message as? TXTextMessageModel {
                let txtMess = ChattorHelpers.createTextMessageModel(uid: messageRealm.creationId, text: textMessage.text, senderId: textMessage.senderId, isIncoming: false, date: messageRealm.date, statusExtended: .sending, allowUnseenSeparator: false)
                chatto.dataSource.slidingDS.messages.append(txtMess)
                chatto.dataSource.delegate?.chatDataSourceDidUpdate(chatto.dataSource)

                //Refresh
                RefreshManager.sharedRM.updateMessage(txtMess)
                
                //Send message
                self.sendMessageToServer(txtMess, messageRealm: messageRealm, timestamp: messageRealm.timestamp)
            }
        }
        //////
    }
    
    //----------------------------------------------------------------------
    // MARK: - status
    
    private func updateMessage(_ message: TXMessageModelProtocol, statusExtended: EGMessageStatus) {
        if message.statusExtended != statusExtended {
            message.statusExtended = statusExtended
            self.notifyMessageChanged(message)
        }
    }
    
    private func notifyMessageChanged(_ message: TXMessageModelProtocol) {
        self.onMessageChanged?(message)
    }
    
}

func isEmptyLists(dict: [String: [String]]) -> Bool {
    for list in dict.values {
        if !list.isEmpty { return false }
    }
    return true
}

