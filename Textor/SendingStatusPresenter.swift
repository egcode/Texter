//
//  SendingStatusPresenter.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class SendingStatusModel: ChatItemProtocol {
    let uid: String
    static var chatItemType: ChatItemType {
        return "decoration-status"
    }

    var type: String { return SendingStatusModel.chatItemType }
    let statusExtended: EGMessageStatus
    let isIncoming:Bool
    
    init (uid: String, statusExtended: EGMessageStatus, isIncoming:Bool) {
        self.uid = uid
        self.statusExtended = statusExtended
        self.isIncoming = isIncoming
    }
}

public class SendingStatusPresenterBuilder: ChatItemPresenterBuilderProtocol {

    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is SendingStatusModel ? true : false
    }

    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return SendingStatusPresenter(
            statusModel: chatItem as! SendingStatusModel
        )
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return SendingStatusPresenter.self
    }
}

class SendingStatusPresenter: ChatItemPresenterProtocol {

    let statusModel: SendingStatusModel
    init (statusModel: SendingStatusModel) {
        self.statusModel = statusModel
    }

    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "SendingStatusCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SendingStatusCollectionViewCell")
    }

    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SendingStatusCollectionViewCell", for: indexPath)
        return cell
    }

    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let statusCell = cell as? SendingStatusCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }
        
        let attrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 10.0),
            NSForegroundColorAttributeName: statusColor()
        ]
        statusCell.text = NSAttributedString(
            string: self.statusText(),
            attributes: attrs)
        
        statusCell.alignment = (statusModel.isIncoming) ? NSTextAlignment.left : NSTextAlignment.right
        statusCell.statusImageView.image = statusImage()
        
        statusCell.statusLabelWidthConstraint.constant = statusCell.label.intrinsicContentSize.width
        statusCell.statusBGWidthConstraint.constant = statusCell.label.intrinsicContentSize.width + 8 + statusCell.statusImageView.frame.width
    }

    func statusText() -> String {
        switch self.statusModel.statusExtended {
        case .failed:
            return NSLocalizedString("Sending failed", comment: "")
        case .sending:
            return NSLocalizedString("Sending...", comment: "")
        case .getting:
            return NSLocalizedString("Getting...", comment: "")
        case .success:
            return NSLocalizedString("Sent", comment: "")
        case .delivered:
            return NSLocalizedString("Delivered", comment: "")
        case .seen:
            return NSLocalizedString("Seen", comment: "")
        }
    }
    
    func statusColor() -> UIColor {
        switch self.statusModel.statusExtended {
        case .failed:
            return UIColor.red
        case .sending:
            return UIColor.lightGray
        case .getting:
            return UIColor.brown
        case .success:
            return UIColor.blue
        case .delivered:
            return UIColor.orange
        case .seen:
            return UIColor(red: 0.44, green: 0.65, blue: 0.02, alpha: 1.0)//Green
        }
    }
    
    func statusImage() -> UIImage {
        switch self.statusModel.statusExtended {
        case .failed:
            return UIImage(named: "status_failed")!
        case .sending:
            return UIImage(named: "status_sending")!
        case .getting:
            return UIImage(named: "status_getting")!
        case .success:
            return UIImage(named: "status_sent")!
        case .delivered:
            return UIImage(named: "status_delivered")!
        case .seen:
            return UIImage(named: "status_seen")!
        }
    }

    var canCalculateHeightInBackground: Bool {
        return true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 19
    }
}
