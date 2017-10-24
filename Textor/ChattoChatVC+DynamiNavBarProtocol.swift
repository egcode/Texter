//
//  ChattoChatVC+DynamiNavBarProtocol.swift
//  Textor
//
//  Created by eugene golovanov on 3/31/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

extension ChattoChatVC : DynamiNavBarProtocol {
    /**
     overriding method from DynamiNavBarProtocol
     to override ChattoChatVC default bar appearance
     showChatLabel instead of showDefaultLabel
     */
    func showDefaultBar() {
        guard let navBar = self.navigationController?.navigationBar as? SpinnerNavigationBar else{magic("navbar err");return}
        GCD.mainThread {
            //Contact Status
            guard let user = DataManager.model.currentUser else { magic("no user"); return }
            if let c = self.dataSource.chatroom {
                for realmString in c.oppositeContactIds {
                    if let cont:Contact = user.getRealm().object(ofType: Contact.self, forPrimaryKey: realmString.contactId) {
                        
                        //Status
                        var status:String = cont.isOnline ? "online" : "offline"
                        //If Last seen timestamp exists
                        if !cont.isOnline && cont.dateLastOnline != nil {
                            if let date = cont.dateLastOnline {
                                let lastSeenDate = DateHelpers.dateStringFromDate(date: date)
                                let timeSeenDate = DateHelpers.timeStringFromDate(date: date)
                                status = "last seen \(lastSeenDate) at \(timeSeenDate)"
                            }
                        }
                        //NavBar
                        navBar.showChatLabel(self.navigationItem, status: status, statusLabelColor: UIColor.gray)
                    }

                }
            }
        }
    }
    
    func showTypingBar(contact:Contact) {
        guard let navBar = self.navigationController?.navigationBar as? SpinnerNavigationBar else{magic("navbar err");return}
        GCD.mainThread {
            //NavBar
            navBar.showChatLabel(self.navigationItem, status: "\(contact.firstName) is Typing...", statusLabelColor: UIColor.orange)
        }
    }
    
}
