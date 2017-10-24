//
//  ChattoHelpers.swift
//  Textor
//
//  Created by eugene golovanov on 10/16/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions
import RealmSwift

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - Convert Realm to Chatto

class ChattorHelpers {
    
    //-----------------------------------------------------------------------------
    // MARK: - Realm

    class func convertRealmToChattoMessage(realmMessage:Message, allowUnseenSeparator:Bool) -> MessageModelProtocol {
        
        guard let user = DataManager.model.currentUser, let placeholderImage = UIImage(named:"placeholder") else {
            magic("no user")
            return EGMessageModel(uid: "", senderId: "", type: "", isIncoming: false, date: Date(), statusExtended: .failed, allowUnseenSeparator: false)
        }
        let isIncoming = (user.id == realmMessage.senderId ? false : true)
        
        //Status
        let status = realmStatusToEGMessageStatus(statusDB: realmMessage.statusDB)
        
        /// PHOTO Message \\\
        if realmMessage.type == MessageType.photo.rawValue {
            if realmMessage.photoData != nil {
                if let photoData = realmMessage.photoData, let photo = UIImage(data: photoData, scale: 1.0) {
                    return createPhotoMessageModel(realmMessage.creationId, image: photo, senderId: realmMessage.senderId, size: photo.size, isIncoming: isIncoming, date: realmMessage.date, statusExtended: status, allowUnseenSeparator: allowUnseenSeparator)
                }
            } else {
                
                let photoMessage = createPhotoMessageModel(realmMessage.creationId, image: placeholderImage, senderId: realmMessage.senderId, size: CGSizeFromString(realmMessage.photoSize), isIncoming: isIncoming, date: realmMessage.date, statusExtended: status, allowUnseenSeparator: allowUnseenSeparator)
                photoMessage.imageUrl = realmMessage.photoUrl
                if isIncoming == true  {
                    photoMessage.statusExtended = .getting
                } else {
                    //Check if we downloading
                    if OperationsManager.sharedOM.downloadsInProgress[photoMessage.uid] != nil {
                        photoMessage.statusExtended = .getting
                    } else {
                        photoMessage.statusExtended = .sending
                    }
                }
                return photoMessage
            }
        }
        
        /// TEXT Message \\\
        guard let decodedText = realmMessage.text.base64Decoded() else {
            magic("no decoded text")
            return EGMessageModel(uid: "", senderId: "", type: "", isIncoming: false, date: Date(), statusExtended: .failed, allowUnseenSeparator: false)
        }
        return createTextMessageModel(uid: realmMessage.creationId, text: decodedText, senderId: realmMessage.senderId, isIncoming: isIncoming, date: realmMessage.date, statusExtended: status, allowUnseenSeparator: allowUnseenSeparator)
    }
    
    class func realmStatusToEGMessageStatus(statusDB:String) -> EGMessageStatus {
        var status = EGMessageStatus.failed
        switch statusDB {
        case MESSAGE_STATUS_NOT_SENT:
            status = .failed
        case MESSAGE_STATUS_SENDING:
            status = .sending
        case MESSAGE_STATUS_GETTING:
            status = .getting
        case MESSAGE_STATUS_SENT:
            status = .success
        case MESSAGE_STATUS_DELIVERED:
            status = .delivered
        case MESSAGE_STATUS_SEEN:
            status = .seen
        default:
            status = .failed
        }
        return status
    }
    
    class func getStatusFromRealm(UID:String) -> EGMessageStatus {
        //find in realm
        guard let outcomeMessage = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: UID) else {
            magic("no outcome message")
            return .failed
        }
        return realmStatusToEGMessageStatus(statusDB: outcomeMessage.statusDB)
    }

    //-----------------------------------------------------------------------------
    // MARK: - Message

    class func createMessageModel(uid: String, senderId: String, type: String, isIncoming: Bool, date: Date, statusExtended: EGMessageStatus, allowUnseenSeparator: Bool) -> EGMessageModel {
        let egMessageModel = EGMessageModel(uid: uid, senderId: senderId, type: type, isIncoming: isIncoming, date: date, statusExtended: statusExtended, allowUnseenSeparator: allowUnseenSeparator)
        return egMessageModel
    }
    
    //-------------------------------------------------------------------------------------------------
    // MARK: - Text message

    class func createTextMessageModel(uid: String, text:String, senderId: String, isIncoming: Bool, date: Date, statusExtended: EGMessageStatus, allowUnseenSeparator: Bool) -> TXTextMessageModel {
        
        let egMessageModel = createMessageModel(uid: uid, senderId: senderId, type: TextMessageModel<EGMessageModel>.chatItemType, isIncoming: isIncoming, date: date, statusExtended: statusExtended, allowUnseenSeparator: allowUnseenSeparator)
        let textMessageModel = TXTextMessageModel(messageModel: egMessageModel, text: text)
        return textMessageModel
    }

    //-------------------------------------------------------------------------------------------------
    // MARK: - Photo message

    class func createPhotoMessageModel(_ uid: String, image: UIImage, senderId: String, size: CGSize, isIncoming: Bool, date: Date, statusExtended: EGMessageStatus, allowUnseenSeparator: Bool) -> TXPhotoMessageModel {
        let egMessageModel = createMessageModel(uid: uid, senderId: senderId, type: PhotoMessageModel<EGMessageModel>.chatItemType, isIncoming: isIncoming, date: date, statusExtended: statusExtended, allowUnseenSeparator: allowUnseenSeparator)
        let photoMessageModel = TXPhotoMessageModel(messageModel: egMessageModel, imageSize:size, image: image)
        return photoMessageModel
    }

    //-------------------------------------------------------------------------------------------------
    // MARK: - Chatroom

    class func getOppositeContactsFromChatroom(_ chatroom:Chatroom) -> [Contact]? {
        if chatroom.oppositeContactIds.count == 1 {
            guard let realmStr = chatroom.oppositeContactIds.first else {magic("No ids");return nil}
            let contactPredicate = NSPredicate(format: "id = %@", realmStr.contactId)
            if let tempArr = DataManager.model.currentUser?.contacts.filter(contactPredicate) {
                return Array(tempArr)
            } else {
                return nil
            }
        }
        return nil
    }
    
    class func convertAllRealmToChattoMessages(chatroom:Chatroom) -> [MessageModelProtocol] {
        var result = [EGMessageModelProtocol]()
        //From REALM
        let chatroomPredicate = NSPredicate(format: "chatroomId = %@", chatroom.id)
        let realmMessagesArray = chatroom.getRealm().objects(Message.self).filter(chatroomPredicate).sorted(byProperty: "timestamp",ascending: true)
        
        //Convert
        for realmMessage in realmMessagesArray {
            let chattoMessage = ChattorHelpers.convertRealmToChattoMessage(realmMessage: realmMessage, allowUnseenSeparator: true)
            result.append(chattoMessage as! EGMessageModelProtocol)
        }
        return result
    }
}

// MARK: - Type of message

extension TextMessageModel {
    static var chatItemType: ChatItemType {
        return MessageType.text.rawValue
    }
}

extension PhotoMessageModel {
    static var chatItemType: ChatItemType {
        return MessageType.photo.rawValue
    }
}
