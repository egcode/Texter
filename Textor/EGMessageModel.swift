//
//  EGMessageModel.swift
//  Textor
//
//  Created by eugene golovanov on 10/3/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import RealmSwift
import Chatto
import ChattoAdditions

public enum EGMessageStatus {
    case failed
    case sending
    case getting
    case success
    case delivered
    case seen
}

public protocol EGMessageModelProtocol: MessageModelProtocol {
    var statusExtended: EGMessageStatus { get }
    var allowUnseenSeparator: Bool { get }

}

open class EGMessageModel: EGMessageModelProtocol {
    open var uid: String
    open var senderId: String
    open var type: String
    open var isIncoming: Bool
    open var date: Date
    open var statusExtended: EGMessageStatus = .success {
        didSet {
            self.status = self.setStatusFromStatusExtended(statusExtended: statusExtended)
        }
    }
    open var status: MessageStatus = .success
    open var allowUnseenSeparator: Bool
    
    public init(uid: String, senderId: String, type: String, isIncoming: Bool, date: Date, statusExtended: EGMessageStatus, allowUnseenSeparator:Bool) {
        self.uid = uid
        self.senderId = senderId
        self.type = type
        self.isIncoming = isIncoming
        self.date = date
        self.statusExtended = statusExtended
        self.allowUnseenSeparator = allowUnseenSeparator
        self.status = self.setStatusFromStatusExtended(statusExtended: statusExtended)
    }
    
    private func setStatusFromStatusExtended(statusExtended: EGMessageStatus) -> MessageStatus {
        switch statusExtended {
        case .failed:
            return .failed
        case .sending:
            return .sending
        case .getting:
            return .sending
        case .success:
            return .success
        case .delivered:
            return .success
        case .seen:
            return .success
        }
        
    }
}
