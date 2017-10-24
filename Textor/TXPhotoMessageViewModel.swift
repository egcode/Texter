//
//  TXPhotoMessageViewModel.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import ChattoAdditions

class TXPhotoMessageViewModel: PhotoMessageViewModel<TXPhotoMessageModel> {

    let fakeImage: UIImage
    override init(photoMessage: TXPhotoMessageModel, messageViewModel: MessageViewModelProtocol) {
        self.fakeImage = photoMessage.image
        super.init(photoMessage: photoMessage, messageViewModel: messageViewModel)
        if photoMessage.isIncoming {
            self.image.value = nil
        }
    }
    override func willBeShown() {
        self.drawProgress()
    }
    
    func drawProgress() {
        
        guard let progr = messageModel.progress else {
            self.transferProgress.value = 1
            self.transferStatus.value = .success
            self.image.value = self.fakeImage
            return
        }
        self.transferProgress.value = progr
        
        switch messageModel.statusExtended {
        case .sending:
            self.transferStatus.value = .transfering
        case .getting:
            self.transferStatus.value = .transfering
        case .failed:
            self.transferStatus.value = .failed
        case .success:
            self.transferStatus.value = .success
        case .delivered:
            self.transferStatus.value = .success
        case .seen:
            self.transferStatus.value = .success
        }
    }

}

extension TXPhotoMessageViewModel: TXMessageViewModelProtocol {
    var messageModel: TXMessageModelProtocol {
        return self._photoMessage
    }
}

class TXPhotoMessageViewModelBuilder: ViewModelBuilderProtocol {

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    func createViewModel(_ model: TXPhotoMessageModel) -> TXPhotoMessageViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(model)
        let photoMessageViewModel = TXPhotoMessageViewModel(photoMessage: model, messageViewModel: messageViewModel)
        photoMessageViewModel.avatarImage.value = UIImage(named: "userAvatar")
        return photoMessageViewModel
    }

    func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is TXPhotoMessageModel
    }
}
