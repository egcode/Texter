//
//  TXPhotoMessageHandler.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import ChattoAdditions

class TXPhotoMessageHandler: BaseMessageInteractionHandlerProtocol {
    private let baseHandler: BaseMessageHandler
    init (baseHandler: BaseMessageHandler) {
        self.baseHandler = baseHandler
    }

    func userDidTapOnFailIcon(viewModel: TXPhotoMessageViewModel, failIconView: UIView) {
        self.baseHandler.userDidTapOnPhotoFailIcon(viewModel: viewModel) // Resend PHOTO Message
    }

    func userDidTapOnAvatar(viewModel: TXPhotoMessageViewModel) {
        self.baseHandler.userDidTapOnAvatar(viewModel: viewModel)
    }

    func userDidTapOnBubble(viewModel: TXPhotoMessageViewModel) {
        self.baseHandler.userDidTapOnPhoto(viewModel: viewModel) // PHOTO Touched
    }

    func userDidBeginLongPressOnBubble(viewModel: TXPhotoMessageViewModel) {
        self.baseHandler.userDidBeginLongPressOnBubble(viewModel: viewModel)
    }

    func userDidEndLongPressOnBubble(viewModel: TXPhotoMessageViewModel) {
        self.baseHandler.userDidEndLongPressOnBubble(viewModel: viewModel)
    }
}
