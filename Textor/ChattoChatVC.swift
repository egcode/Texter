//
//  ChattoChatVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/18/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions

enum Segue:String {
    case statusHistory = "statusHistorySegue"
    case contact = "contactSegue"
}

class ChattoChatVC: BaseChatViewController {

    //---------------------------------------------------------------------------------
    // MARK: - Properties

    var messageSender: TXMessageSender!
    var dataSource: TXMessageDataSource! {
        didSet {
            self.chatDataSource = self.dataSource
            self.chatDataSourceDidUpdate(self.dataSource)
        }
    }

    lazy private var baseMessageHandler: BaseMessageHandler = {
        return BaseMessageHandler(messageSender: self.messageSender)
    }()

    var isDisplaying = false
    
    ////////////////////
    //Typing receiving
    class TimerTargetWrapper {
        weak var interactor: ChattoChatVC?
        init(interactor: ChattoChatVC) {
            self.interactor = interactor
        }
        @objc func timerFunctionIn(timer: Timer?) {
            interactor?.timerTypingIn()
        }
        @objc func timerFunctionOutBlock(timer: Timer?) {
            interactor?.timerTypingOutBlock()
        }
    }
    var timer:Timer?
    var count:Int = TYPING_RECEIVE_WAIT
    //Typing sending
    var timerTypeOutBlock:Timer?
    var countTypeOutBlock:Int = TYPING_SEND_WAIT
    ////////////////////

    var backButtonDelegate: BackButtonEditable?
    
    @IBOutlet weak var imageViewOppositeAvatar: PieImageLoader!
    //---------------------------------------------------------------------------------
    // MARK: - View Lifecycle

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.sharedInstance.chattoDelegate = self // Make new chatto vc delegate

        //Back button
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton

        //Title
        guard let user = DataManager.model.currentUser else { magic("no user"); return }
        var vcTitle = ""
        if let c = self.dataSource.chatroom {
            for realmString in c.oppositeContactIds {
                if let cont:Contact = user.getRealm().object(ofType: Contact.self, forPrimaryKey: realmString.contactId) {
                    vcTitle += "\(cont.fullName) "
                    
                    //Image from cache
                    if let img = DataManager.imageCache.object(forKey: cont.avatarUrl as NSString) {
                        self.imageViewOppositeAvatar.image = img
                    } else {
                        self.imageViewOppositeAvatar.getImageWithUrl(avatarUrl: cont.avatarUrl)
                    }
                }
            }
        }
        self.title = vcTitle
        
        //
        let image = UIImage(named: "bubble-incoming-tail-border", in: Bundle(for: ChattoChatVC.self), compatibleWith: nil)?.bma_tintWithColor(.blue)
        super.chatItemsDecorator = TXChatItemsDecorator()
//        let addIncomingMessageButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(ChattoChatVC.addRandomIncomingMessage))
//        self.navigationItem.rightBarButtonItem = addIncomingMessageButton
        
        //BG Image
        if let patternImage = UIImage(named: "messageBG") {
            view.backgroundColor = UIColor(patternImage: patternImage)
        }
        
        //If someone will change status while user offline we won't update it
        self.checkOutcomeMessagesStatus()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isDisplaying = true
        
        self.backButtonDelegate?.backButton(badge: self.updateBackButtonBadge())
        
        //DynamiNavBarProtocol
        self.connectionCheck()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //View Controller Popped
        if self.isBeingDismissed || self.isMovingFromParentViewController {
            self.isDisplaying = false
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.incomeAllMessagesMakeSeen()
        
        self.dataSource.downloadAllImages()
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: - init deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //DynamiNavBarProtocol
        self.registerNotifications()
    }
    
    deinit {
        self.timerTypeOutBlock?.invalidate()
        self.timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    //------------------------------------------------------------------------------
    // MARK: - Back Button Badge
    
    func updateBackButtonBadge() -> String {
        var badge: Int = 0
        var badgeMessage = ""
        
        guard let c = DataManager.model.currentUser?.chatrooms.filter({$0.id != self.dataSource.chatroom?.id}) else {magic("no chatrooms")
            return ""
        }
        
        for ch in c {
            badge += ch.badge
        }
        
        if badge <= 0 {
            badgeMessage = ""
        } else {
            self.tabBarController?.tabBar.items?[1].badgeValue = "\(badge)"
            badgeMessage = "\(badge)"
        }
        return badgeMessage
    }

    //---------------------------------------------------------------------------------------------------------
    // MARK: - Make messages Seen
    
    func incomeAllMessagesMakeSeen() {
        self.dataSource.incomeAllMessagesMakeSeen()
    }
    
    /**
     If someone will change status while user offline we won't update it
     */
    func checkOutcomeMessagesStatus() {
        self.dataSource.checkOutcomeMessagesStatus()
    }
    
    //---------------------------------------------------------------------------------------------------------
    //MARK: - -BaseChatViewController-

    var chatInputPresenter: EGBasicChatInputBarPresenter!
    override func createChatInputView() -> UIView {
        let chatInputView = EGChatInputBar.loadNib()
        chatInputView.typingAction = { [weak self] in
            if let sSelf = self {
                sSelf.sendTypingWithTimer()
            }
        }
        var appearance = EGChatInputBarAppearance()
        appearance.sendButtonAppearance.title = NSLocalizedString("Send", comment: "")
        appearance.textInputAppearance.placeholderText = NSLocalizedString("Type a message", comment: "")
        self.chatInputPresenter = EGBasicChatInputBarPresenter(chatInputBar: chatInputView, chatInputItems: self.createChatInputItems(), chatInputBarAppearance: appearance)
        chatInputView.maxCharactersCount = 1000
        return chatInputView
    }

    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {

        let textMessagePresenter = EGTextMessagePresenterBuilder(// here removed 'Copy' menuitem from text message
            viewModelBuilder: TXTextMessageViewModelBuilder(),
            interactionHandler: TXTextMessageHandler(baseHandler: self.baseMessageHandler)
        )
        textMessagePresenter.baseMessageStyle = BaseMessageCollectionViewCellAvatarStyle()

        let photoMessagePresenter = PhotoMessagePresenterBuilder(
            viewModelBuilder: TXPhotoMessageViewModelBuilder(),
            interactionHandler: TXPhotoMessageHandler(baseHandler: self.baseMessageHandler)
        )
        photoMessagePresenter.baseCellStyle = BaseMessageCollectionViewCellAvatarStyle()

        return [
            TXTextMessageModel.chatItemType: [
                textMessagePresenter
            ],
            TXPhotoMessageModel.chatItemType: [
                photoMessagePresenter
            ],
            SendingStatusModel.chatItemType: [SendingStatusPresenterBuilder()],
            TimeSeparatorModel.chatItemType: [TimeSeparatorPresenterBuilder()],
            UnseenStatusModel.chatItemType: [UnseenStatusPresenterBuilder()]

        ]
    }

    func createChatInputItems() -> [ChatInputItemProtocol] {
        var items = [ChatInputItemProtocol]()
        items.append(self.createTextInputItem())
        items.append(self.createPhotoInputItem())
        return items
    }

    private func createTextInputItem() -> EGTextChatInputItem {
        let item = EGTextChatInputItem() // Added custom class to trim input
        item.textInputHandler = { [weak self] text in
            self?.checkPermission(completion: { (permitted) in
                if permitted {
                    self?.dataSource.sendTextMessage(text)
                }
            })
        }
        return item
    }

    private func createPhotoInputItem() -> PhotosChatInputItem {
        let item = PhotosChatInputItem(presentingController: self)
        item.photoInputHandler = { [weak self] image in
            self?.checkPermission(completion: { (permitted) in
                if permitted {
                    self?.dataSource.sendPhotoMessage(image)
                }
            })
        }
        return item
    }
    
    //---------------------------------------------------------------------------------------------------------
    // MARK: - Unexisted contact check

    func checkPermission(completion: @escaping (_ permitted: Bool) -> Void) {
        SocketIOManager.sharedInstance.checkConnection({ [weak self] (connected) in
            guard let chrm = self?.dataSource.chatroom else { magic("no chatroom"); completion(false); return }
            if connected {
                if chrm.isInvalidated {
                    completion(false)
                    self?.alert("This contact is not in your list anymore")
                } else {
                    completion(true)
                }
            } else {
                completion(false)
                self?.alert("No Internet connection")
            }
        })
    }
    
    //---------------------------------------------------------------------------------------------------------
    // MARK: - Image Tapped
    
    func photoTapped(image:UIImage) {
        let imageViewer = ImageViewer()
        imageViewer.image = image
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(imageViewer, animated: true)
    }
    //---------------------------------------------------------------------------------------------------------
    // MARK: - Contact Tapped

    @IBAction func onContactButton(_ sender: UIButton) {
        print("Contact Button Tapped")
        guard let user = DataManager.model.currentUser else { magic("no user"); return }
        if let c = self.dataSource.chatroom {
            for realmString in c.oppositeContactIds {
                if let cont:Contact = user.getRealm().object(ofType: Contact.self, forPrimaryKey: realmString.contactId) {
                    self.performSegue(withIdentifier: Segue.contact.rawValue, sender: cont)
                }
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------------------
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.statusHistory.rawValue {
            if let vc = segue.destination as? StatusHistoryVC, let m = sender as? Message {
                vc.message = m
            }
        } else if segue.identifier == Segue.contact.rawValue {
            if let vc = segue.destination as? ContactVC, let c = sender as? Contact {
                vc.contact = c
                vc.avatarImage = self.imageViewOppositeAvatar.image
            }
        }
    }
    
}
