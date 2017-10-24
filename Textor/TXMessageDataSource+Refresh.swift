//
//  TXMessageDataSource+Refresh.swift
//  Textor
//
//  Created by eugene golovanov on 10/21/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions
import RealmSwift

extension TXMessageDataSource: RefreshManagerDelegate {

    func reloadMessageFromManager(_ message: TXMessageModelProtocol) {
        
        for (index, m) in self.slidingDS.messages.enumerated() {
            if m.uid == message.uid {
                self.slidingDS.messages[index] = message
                self.delegate?.chatDataSourceDidUpdate(self)
            }
        }
    }
}
