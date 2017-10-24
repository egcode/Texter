//
//  UnseenStatusPresenter.swift
//  Textor
//
//  Created by eugene golovanov on 11/7/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

class UnseenStatusModel: ChatItemProtocol {
    let uid: String
    static var chatItemType: ChatItemType {
        return "decoration1-status"
    }
    
    var type: String { return UnseenStatusModel.chatItemType }
    
    init (uid: String) {
        self.uid = uid
    }
}

public class UnseenStatusPresenterBuilder: ChatItemPresenterBuilderProtocol {
    
    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is UnseenStatusModel ? true : false
    }
    
    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return UnseenStatusPresenter(
            statusModel: chatItem as! UnseenStatusModel
        )
    }
    
    public var presenterType: ChatItemPresenterProtocol.Type {
        return UnseenStatusPresenter.self
    }
}

class UnseenStatusPresenter: ChatItemPresenterProtocol {
    
    let statusModel: UnseenStatusModel
    init (statusModel: UnseenStatusModel) {
        self.statusModel = statusModel
    }
    
    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "UnseenStatusCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UnseenStatusCollectionViewCell")
    }
    
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UnseenStatusCollectionViewCell", for: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let statusCell = cell as? UnseenStatusCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }
    }
    
    var canCalculateHeightInBackground: Bool {
        return true
    }
    
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 19
    }
}
