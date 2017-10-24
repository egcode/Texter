//
//  RefreshManager.swift
//  Textor
//
//  Created by eugene golovanov on 10/21/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import ChattoAdditions
import Chatto

protocol RefreshManagerDelegate {
    func reloadMessageFromManager(_ message: TXMessageModelProtocol)
}

class RefreshManager {
    
    var delegate: RefreshManagerDelegate?
    static let sharedRM = RefreshManager()


    func updateMessage(_ message: TXMessageModelProtocol) {
        self.delegate?.reloadMessageFromManager(message)
    }
    
}
