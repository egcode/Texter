//
//  TXPhotoMessageModel.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//


import Foundation
import ChattoAdditions

public class TXPhotoMessageModel: PhotoMessageModel<EGMessageModel>, TXMessageModelProtocol {
    public override init(messageModel: EGMessageModel, imageSize: CGSize, image: UIImage) {
        super.init(messageModel: messageModel, imageSize: imageSize, image: image)
    }
    
    public var imageUrl: String?
    
    public var progress: Double?

    public var allowUnseenSeparator: Bool {
        get {
            return self._messageModel.allowUnseenSeparator
        }
        set {
            self._messageModel.allowUnseenSeparator = newValue
        }
    }

    
    public var statusExtended: EGMessageStatus {
        get {
            return self._messageModel.statusExtended
        }
        set {
            self._messageModel.statusExtended = newValue
        }
    }



}
