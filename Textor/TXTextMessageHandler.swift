//
//  TXTextMessageHandler.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import ChattoAdditions

class TXTextMessageHandler: BaseMessageInteractionHandlerProtocol {
    private let baseHandler: BaseMessageHandler
    init (baseHandler: BaseMessageHandler) {
        self.baseHandler = baseHandler
    }

    func userDidTapOnFailIcon(viewModel: TXTextMessageViewModel, failIconView: UIView) {
        self.baseHandler.userDidTapOnTextFailIcon(viewModel: viewModel)
    }

    func userDidTapOnAvatar(viewModel: TXTextMessageViewModel) {
        self.baseHandler.userDidTapOnAvatar(viewModel: viewModel)
    }

    func userDidTapOnBubble(viewModel: TXTextMessageViewModel) {
        self.baseHandler.userDidTapOnBubble(viewModel: viewModel)
    }

    func userDidBeginLongPressOnBubble(viewModel: TXTextMessageViewModel) {
        self.baseHandler.userDidBeginLongPressOnBubble(viewModel: viewModel)
    }

    func userDidEndLongPressOnBubble(viewModel: TXTextMessageViewModel) {
        self.baseHandler.userDidEndLongPressOnBubble(viewModel: viewModel)
    }
}
