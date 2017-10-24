//
//  TXTextMessageViewModel.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import ChattoAdditions

public class TXTextMessageViewModel: TextMessageViewModel<TXTextMessageModel>, TXMessageViewModelProtocol {

    public override init(textMessage: TXTextMessageModel, messageViewModel: MessageViewModelProtocol) {
        super.init(textMessage: textMessage, messageViewModel: messageViewModel)
    }

    public var messageModel: TXMessageModelProtocol {
        return self.textMessage
    }
}

public class TXTextMessageViewModelBuilder: ViewModelBuilderProtocol {
    public init() { }

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    public func createViewModel(_ textMessage: TXTextMessageModel) -> TXTextMessageViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(textMessage)
        let textMessageViewModel = TXTextMessageViewModel(textMessage: textMessage, messageViewModel: messageViewModel)
        textMessageViewModel.avatarImage.value = UIImage(named: "userAvatar")
        return textMessageViewModel
    }

    public func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is TXTextMessageModel
    }
}
