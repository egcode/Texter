//
//  ChattoChatVC+Typing.swift
//  Textor
//
//  Created by Eugene Golovanov on 4/10/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

extension ChattoChatVC {
    //---------------------------------------------------------------------------------------------------------
    //MARK: - Typing Received
    
    func typingReceived(contact:Contact) {
        GCD.mainThread {
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: TimerTargetWrapper(interactor: self), selector: #selector(TimerTargetWrapper.timerFunctionIn), userInfo: nil, repeats: true)
                self.showTypingBar(contact: contact)///Typing BAR
            } else {
                self.count = TYPING_RECEIVE_WAIT
            }
        }
    }
    
    func timerTypingIn() {
        self.count -= 1
        print("Typing IN COUNTER: \(count)")
        
        if self.count == 0 {
            self.timer?.invalidate()
            self.timer = nil
            self.count = TYPING_RECEIVE_WAIT
            SocketIOManager.sharedInstance.checkConnection({ [weak self] (connected) in
                if connected {
                    self?.showDefaultBar()///Default BAR
                }
            })
        }
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: - Typing Sending
    
    /**
     Actual Sending Typing Function
     */
    private func sendTyping() {
        //Send typing
        if let chatroomId = self.dataSource.chatroom?.id, let userId = DataManager.model.currentUser?.id {
            print("Typing OUT: chatroomId: \(chatroomId)   typerId:\(userId)")
            SocketIOManager.sharedInstance.sendTypingMade(chatroomId, userId: userId)
        }
    }

    func sendTypingWithTimer() {
        if self.countTypeOutBlock == TYPING_SEND_WAIT {
            GCD.mainThread {
                if self.timerTypeOutBlock == nil {
                    self.timerTypeOutBlock = Timer.scheduledTimer(timeInterval: 1.0, target: TimerTargetWrapper(interactor: self), selector: #selector(TimerTargetWrapper.timerFunctionOutBlock), userInfo: nil, repeats: true)
                    //Send typing
                    self.sendTyping()
                }
            }
        }
    }
    
    func timerTypingOutBlock() {
        
        self.countTypeOutBlock -= 1
        print("Typing OUT Blocker COUNTER: \(countTypeOutBlock)")
        
        if self.countTypeOutBlock == 0 {
            self.timerTypeOutBlock?.invalidate()
            self.timerTypeOutBlock = nil
            self.countTypeOutBlock = TYPING_SEND_WAIT
        }
    }

}
