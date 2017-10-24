//
//  ChatroomsTVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/30/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import RealmSwift
import Chatto
import ChattoAdditions

class ChatroomsTVC: TextorTVC {

    //------------------------------------------------------------------------------
    // MARK: - Properties
    
    var user: User? = {
        return DataManager.model.currentUser
    }()

    var chatrooms:List<Chatroom> {
        if let arr =  DataManager.model.currentUser?.chatrooms {
            let tmpArr = Array(arr).filter({ (chatroom) -> Bool in
                return chatroom.isHidden == false
            }).sorted(by: {$0.date > $1.date})
            return List(tmpArr)
        } else {
            return List<Chatroom>()
        }
    }
        
    //------------------------------------------------------------------------------
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Chatrooms"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBadge"), object: nil)
        self.tabBarController?.tabBar.isHidden = false
    }
        
    //------------------------------------------------------------------------------
    //MARK: - init deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatroomsTVC.reloadTableView), name: NSNotification.Name(rawValue: "reloadChatrooms"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatroomsTVC.reloadChatroomsFromServer), name: NSNotification.Name(rawValue: "reloadChatroomsFromServer"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ChatroomsTVC.typingReceived), name: NSNotification.Name(rawValue: "typingReceived"), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: - Typing
    
    func typingReceived(notification:Notification) {
        guard let chatroomId = notification.object as? String else {  magic("no chatroom id");  return  }
        
        if let cells = self.tableView.visibleCells as? [ChatroomCell] {
            let typeCells = cells.filter({ $0.chatroomId == chatroomId})
            for c in typeCells {
                c.typingReceived()
            }
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: - Refresh

    func reloadChatroomsFromServer() {
        guard let user = self.user else {magic("no user");return}
        SocketIOManager.sharedInstance.chatroomsGetAndReconnect(user.id) { [weak self] (chatrooms) in
            GCD.mainThread {
                for chatroom in chatrooms {
                    let id  = (chatroom["_id"] as? String ?? "").trim()
                    if user.chatrooms.contains( where: { $0.id == id } ) == false {
                        
                        let chrm = Chatroom(data: chatroom)
                        user.write({
                            user.chatrooms.append(chrm)
                        })
                        //Fetch first page of messages if exist
                        SocketIOManager.sharedInstance.fetchMessagesPageForChatroom(chatroom: chrm, user: user)
                        
                        self?.tableView.reloadData()
                    } else {
                        print("chatroom already cached")
                    }
                }
            }
        }
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
//        self.tableView.reloadSections(IndexSet(integersIn: 0..<tableView.numberOfSections), with: .fade)
    }

    //------------------------------------------------------------------------------
    // MARK: - -Table view-

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatroomCell", for: indexPath) as! ChatroomCell
        cell.configureWithChatroom(self.chatrooms[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChatroom = self.chatrooms[indexPath.row]
        self.performSegue(withIdentifier: "ChattoSegue", sender: selectedChatroom)
    }
    
    //------------------------------------------------------------------------------
    // MARK: Table view slide

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let chatroomToDelete = self.chatrooms[indexPath.row]
            self.deleteChatroomPrompt(chatroomToDelete)
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: - Delete chatroom prompt

    private func deleteChatroomPrompt(_ chatroomToDelete:Chatroom) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "All Messages from chatroom will be deleeted!", preferredStyle: .actionSheet)
        
        // delete chatroom
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction) -> Void in
            print("delete tapped")
            print(chatroomToDelete)
            self.makeChatroomHidden(chatroom: chatroomToDelete)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func makeChatroomHidden(chatroom:Chatroom) {
        guard let user = self.user else {magic("user error");return}
        
        self.deleteAllChatroomMessages(token: user.token, chatroomId: chatroom.id) { (success) in
            if success {
                GCD.mainThread(block: { 
                    user.write({
                        chatroom.isHidden = true
                        chatroom.getRealm().delete(chatroom.messages)
                    })
                    self.reloadTableView()
                })
            } else {
                self.alert("Failed to delete chatroom", title: "Failure")
            }
        }
        
    }

    //DELETE /chatroom/:id
    private func deleteAllChatroomMessages(token:String, chatroomId:String, completionSuccess: @escaping (_ success:Bool) -> Void) {
        let url = URL_API + "/chatroom/" + chatroomId
        API.delete(url as AnyObject , userToken: token) { (response) in
            if response.success == true {
                print("Delete Chatroom SUCCESS")
                completionSuccess(true)
            } else {
                print("Delete Chatroom Failure")
                completionSuccess(false)
            }
        }
    }

    //------------------------------------------------------------------------------
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.tabBarController?.tabBar.isHidden = true
        //Chatto
        if segue.identifier == "ChattoSegue" {
            if let  vc = segue.destination as? ChattoChatVC,
                let selectedChatroom = sender as? Chatroom {
                let dataSource = TXMessageDataSource(chatroom: selectedChatroom)
                dataSource.user = self.user
                dataSource.chatroom = selectedChatroom
                vc.dataSource = dataSource
                vc.messageSender = dataSource.messageSender
                RefreshManager.sharedRM.delegate = dataSource // Addigning New Datasource as a UPLOAD delegate
                
                vc.messageSender.chattoVC = vc //Handler For message resending
                
                let backButton = UIBarButtonItem()
                backButton.title = ""
                self.navigationItem.backBarButtonItem = backButton
                vc.backButtonDelegate = self
            }
        }
    }

}

//--------------------------------------------------------------------
//--------------------------------------------------------------------
// MARK: - BackButtonEditable protocol

protocol BackButtonEditable {
    func backButton(badge:String)
}

extension ChatroomsTVC: BackButtonEditable {
    func backButton(badge: String) {
        let backButton = UIBarButtonItem()
        backButton.title = badge
        self.navigationItem.backBarButtonItem = backButton
    }
}
