//
//  TXChatItemsDecorator.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

final class TXChatItemsDecorator: ChatItemsDecoratorProtocol {
    struct Constants {

        static let shortSeparation: CGFloat = 3
        static let normalSeparation: CGFloat = 10
        
        static let timeIntervalThresholdToIncreaseSeparation: TimeInterval = 344
    }

    func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem] {
        var decoratedChatItems = [DecoratedChatItem]()
        let calendar = Calendar.current

        let lastOutgoing = chatItems.filter({
            if let currentMessage = $0 as? EGMessageModelProtocol {
                return currentMessage.isIncoming == false
            } else {
                return false
            }
        }).last as? EGMessageModelProtocol
        
        for (index, chatItem) in chatItems.enumerated() {
            let next: ChatItemProtocol? = (index + 1 < chatItems.count) ? chatItems[index + 1] : nil
            let prev: ChatItemProtocol? = (index > 0) ? chatItems[index - 1] : nil

            let bottomMargin = self.separationAfterItem(chatItem, next: next)
            var showsTail = true
            var additionalItems =  [DecoratedChatItem]()
            
            var addTimeSeparator = false
            if let currentMessage = chatItem as? EGMessageModelProtocol {
                if let nextMessage = next as? EGMessageModelProtocol {
                    showsTail = currentMessage.senderId != nextMessage.senderId
                } else {
                    showsTail = true
                }

                if let previousMessage = prev as? EGMessageModelProtocol {
                    addTimeSeparator = calendar.compare(currentMessage.date, to: previousMessage.date, toGranularity: Calendar.Component.day) != ComparisonResult.orderedSame
                } else {
                    addTimeSeparator = true
                }
                
                //Unseen Messages separator
                if let prevMessage = prev as? EGMessageModelProtocol {
                    if currentMessage.allowUnseenSeparator == true && currentMessage.statusExtended != .seen && currentMessage.isIncoming == true && prevMessage.statusExtended == .seen  {

                        let unseenSeparator = DecoratedChatItem(
                        chatItem: UnseenStatusModel(uid: "\(currentMessage.uid)-decoration1-status"),
                        decorationAttributes: nil)
                    decoratedChatItems.append(unseenSeparator)
                        }
                }

                //Message Status
                if currentMessage.isIncoming == false && currentMessage.statusExtended != .seen ||
//                    currentMessage.isIncoming == false && currentMessage.uid == chatItems.last?.uid {
                    currentMessage.isIncoming == false && currentMessage.uid == lastOutgoing?.uid {

                    if self.showsStatusForMessage(currentMessage) {
                        additionalItems.append(
                            DecoratedChatItem(
                                chatItem: SendingStatusModel(uid: "\(currentMessage.uid)-decoration-status", statusExtended: currentMessage.statusExtended, isIncoming: currentMessage.isIncoming),
                                decorationAttributes: ChatItemDecorationAttributes(bottomMargin: Constants.shortSeparation, showsTail: false, canShowAvatar: false))
                        )
                    }
                }
                
                if addTimeSeparator {
                    let dateTimeStamp = DecoratedChatItem(chatItem: TimeSeparatorModel(uid: "\(currentMessage.uid)-time-separator", date: currentMessage.date.toWeekDayAndDateString()), decorationAttributes: nil)
                    decoratedChatItems.append(dateTimeStamp)
                }
            }

            decoratedChatItems.append(DecoratedChatItem(
                chatItem: chatItem,
                decorationAttributes: ChatItemDecorationAttributes(bottomMargin: bottomMargin, showsTail: showsTail, canShowAvatar: showsTail))
            )
            decoratedChatItems.append(contentsOf: additionalItems)
        }

        return decoratedChatItems
    }

    func separationAfterItem(_ current: ChatItemProtocol?, next: ChatItemProtocol?) -> CGFloat {
        guard let nexItem = next else { return 0 }
        guard let currentMessage = current as? EGMessageModelProtocol else { return Constants.normalSeparation }
        guard let nextMessage = nexItem as? EGMessageModelProtocol else { return Constants.normalSeparation }

        if self.showsStatusForMessage(currentMessage) && currentMessage.isIncoming {
            //Between income bubbles
            return Constants.shortSeparation
            
        } else if self.showsStatusForMessage(currentMessage) && !currentMessage.isIncoming {
            //Between outcome bubbles
            return Constants.shortSeparation

        } else if currentMessage.senderId != nextMessage.senderId {
            //Between income and outcome
            return 0
        } else if nextMessage.date.timeIntervalSince(currentMessage.date) > Constants.timeIntervalThresholdToIncreaseSeparation {
            return 0
        } else {
            return 0
        }
    }

    func showsStatusForMessage(_ message: EGMessageModelProtocol) -> Bool {
        return message.statusExtended == .failed || message.statusExtended == .sending || message.statusExtended == .success || message.statusExtended == .seen || message.statusExtended == .getting || message.statusExtended == .delivered
    }
}
