//
//  ContactsTVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/9/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire

class ContactsTVC: TextorTVC {

    //--------------------------------------------------------------------
    // MARK: - Properties
    var contacts = [Contact]()
    var requests = [Contact]()
    
    var user: User? = {
        return DataManager.model.currentUser
    }()

    @IBOutlet weak var barButtonEdit: UIBarButtonItem!
    @IBOutlet weak var barButtonSearch: UIBarButtonItem!
    @IBOutlet weak var barButtonRequests: UIButton!
    
    @IBOutlet weak var viewAvatar: PieImageLoader!
    @IBOutlet weak var labelFirstName: UILabel!
    @IBOutlet weak var labelLastName: UILabel!
    
    weak var avatarRequest: Alamofire.Request?

    //--------------------------------------------------------------------
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //BG Image multiplyed to bgcolor
        let bgImageView = UIImageView(image: UIImage(named: "messageBG")?.multiplyToColor(UIColor.groupTableViewBackground))
        bgImageView.frame = UIScreen.main.bounds
        bgImageView.alpha = 0.3
        self.view.insertSubview(bgImageView, at: 0)
        
        self.barButtonRequests.layer.cornerRadius = min(self.barButtonRequests.frame.width/2, self.barButtonRequests.frame.height/2)        
        self.navigationController?.navigationBar.topItem?.title = "Contacts"
        
        self.refreshConnect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //--------------------------------------------------------------------
    //MARK: - init deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.refreshConnect), name: NSNotification.Name(rawValue: "refreshConnect"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.refreshContactsFromServer), name: NSNotification.Name(rawValue: "refreshContactsFromServer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.setAllContactsOffline), name: NSNotification.Name(rawValue: "setAllContactsOffline"), object: nil)

        //User Status changed
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.contactStatusChanged(_:)), name: NSNotification.Name(rawValue: "statusChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.refreshFriendRequests), name: NSNotification.Name(rawValue: "refreshRequests"), object: nil)
        
        //Badge Global
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.refreshBadge), name: NSNotification.Name(rawValue: "refreshBadge"), object: nil)
        
        //Contact Deleted on server
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.deleteContactFromSocket(_:)), name: NSNotification.Name(rawValue: "friendDeleted"), object: nil)
        
        //We blocked user and we need to delete it
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsTVC.deleteContactFromBlock(_:)), name: NSNotification.Name(rawValue: "friendBlocked"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------------------------------------
    //MARK: - UI
    
    func setupUI() {
        var firstName = ""
        var lastName = ""
        if let fn = DataManager.model.currentUser?.firstName {  firstName = fn    }
        if let ln = DataManager.model.currentUser?.lastName {   lastName = ln   }
        self.labelFirstName.text = firstName
        self.labelLastName.text = lastName

        //Avatar download
        guard let avatarUrl = DataManager.model.currentUser?.avatarUrl else {   magic("no avatar url"); return   }
        self.viewAvatar.getImageWithUrl(avatarUrl: avatarUrl)
    }
    
    //--------------------------------------------------------------------
    //MARK: - Observing users Connected Disconnected
    
    func contactStatusChanged(_ notification: Notification) {
        guard let updContact = notification.object as? Contact else { magic("problem with upd contact"); return }
        guard let user = self.user else { magic("user error"); return }

        for (index,contact) in self.contacts.enumerated() {
            if contact.id == updContact.id {
                user.write {
                    contact.isOnline = updContact.isOnline
                    contact.dateLastOnline = updContact.dateLastOnline
                }
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    //--------------------------------------------------------------------
    // MARK: - Contacts

    /**
     Check if we have odd contacts in realm, delete them and chatrooms and messages in chatroom
     */
    private func checkDeletedContacts() {
        guard let user = self.user else {magic("user error");return}
        
        //Loop through all realm contacts an compare if its exist on server contacts
        for realmContact in user.contacts {
            if self.contacts.contains(where: { $0.id == realmContact.id }) {
                print("Exists on server: \(realmContact.fullName)")
            } else {
                print("Need To Delete: \(realmContact.fullName)")
                self.deleteContact(realmContact.id, fromPrompt: false)
            }
        }
    }
    
    func setAllContactsOffline() {
        guard let user = self.user else { magic("user error"); return }
        user.write {
            for contact in user.contacts { contact.isOnline = false }
            for c in self.contacts { c.isOnline = false }
        }
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    //--------------------------------------------------------------------
    // MARK: - Refreshers
    
    func refreshConnect() {
        guard let user = self.user else {
            InitialVC.showLogin()
            User.logout({ (completed) in
                magic("Unpredictable Logout")
            })
            magic("User Error")
            return
        }
        
        self.setupUI()
        
        SocketIOManager.sharedInstance.getContacts(user.email, id: user.id, completion: {[weak self] contactsData in
            
            self?.refreshContacts(contactsData: contactsData)
            self?.refreshFriendRequests()
            self?.checkDeletedContacts()
            self?.setupUI()
            
            DataManager.needLoginTransition = false
            
            GCD.mainThread(block: {
                self?.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
                NotificationCenter.default.post(name: Notification.Name(rawValue: BarType.showDefault.rawValue), object: nil)
            })
        })
    }
    
    func refreshContactsFromServer() {

        let url = URL_API + "/friends"
        guard let token = DataManager.model.currentUser?.token else {magic("token problem");return}
        
        API.get(url as AnyObject, userToken: token) { (response) in
            if response.code == 200 && response.success == true {
                
                if let contactsData = response.dataArray {
                    GCD.mainThread(block: { 
                        self.refreshContacts(contactsData: contactsData)
                    })
                }
            }
        }

    }
    
    private func refreshContacts(contactsData: [[String: AnyObject]]) {
        
        self.contacts.removeAll()
        guard let user = DataManager.model.currentUser else {magic("no user");return}

        for data in contactsData {
            let contact = Contact(data: data)
            self.contacts.append(contact)
            
            if user.contacts.contains( where: { $0.id == contact.id } ) == false {
                user.write({
                    user.contacts.append(contact)
                })
            }
        }
        
        self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    func refreshFriendRequests() {
        
        let url = URL_API + "/requestsincoming/"
        guard let token = DataManager.model.currentUser?.token else {magic("token problem");return}

        API.get(url as AnyObject, userToken: token) { (response) in
            if response.code == 200 && response.success == true {
                self.requests.removeAll()
                if let dataArray = response.dataArray {
                    for data in dataArray {
                        let request = Contact(data: data)
                        self.requests.append(request)
                    }
                }
                GCD.mainThread(block: {
                    self.refreshBadge()
                    if self.requests.count > 0 {
                        self.barButtonRequests.isEnabled = true
                        self.barButtonRequests.isHidden = false
                        self.barButtonRequests.setTitle("\(self.requests.count)", for: .normal)
                        self.barButtonRequests.tintColor = UIColor.orange
                    } else {
                        self.barButtonRequests.isEnabled = false
                        self.barButtonRequests.isHidden = true
                        self.barButtonRequests.setTitle("", for: .normal)
                    }
                })
            } else {
                GCD.mainThread(block: { 
                    self.alert("error getting contactrequests")
                })
            }
        }
    }
    
    func refreshBadge() {
        var badgeMessages = 0
        guard let chatrooms = DataManager.model.currentUser?.chatrooms else {magic("no chatrooms");return}
        for chatroom in chatrooms {
            badgeMessages += chatroom.badge
        }
        if badgeMessages <= 0 {
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
        } else {
            self.tabBarController?.tabBar.items?[1].badgeValue = "\(badgeMessages)"
        }
        
        let badgeGlobal = self.requests.count + badgeMessages
        UIApplication.shared.applicationIconBadgeNumber = badgeGlobal
    }
    
    func updateContactsOrderOnServerFromLocal() {
        
        let url = URL_API + "/friends/reorder"
        guard let token = DataManager.model.currentUser?.token else {magic("token problem");return}
        
        var idsArray = Array<String>()
        for cont in self.contacts { idsArray.append(cont.id)}
        let payload = ["reorderedContacts": idsArray]

        API.put(url as AnyObject, payload: payload as [String : AnyObject]?, userToken: token) { (response) in
            if response.code == 200 && response.success == true {
                print("Successfully uploaded contacts on Server")
            }
        }
    }

    //--------------------------------------------------------------------
    // MARK: - Actions
    
    @IBAction func onEditBarButton(_ sender: UIBarButtonItem) {
        if self.isEditing {
            self.barButtonEdit.image = UIImage(named: "edit")
            self.setEditing(false, animated: true)
            self.updateContactsOrderOnServerFromLocal()
        } else {
            self.barButtonEdit.image = UIImage(named: "notEdit")
            self.setEditing(true, animated: true)
        }
    }
    
    @IBAction func onProfileButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "accountSegue", sender: nil)
    }
    
    @IBAction func onBarButtonSearch(_ sender: UIBarButtonItem) {
        magic("onBarButtonSearch")
        performSegue(withIdentifier: "searchContactsSegue", sender: self)
    }

    @IBAction func onBarButtonRequests(_ sender: UIButton) {
        magic("onBarButtonRequests")
        performSegue(withIdentifier: "incomeRequestSegue", sender: self)
    }
    
    //--------------------------------------------------------------------
    // MARK: - -Table view data source-

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellContacts") as? ContactsCell else {
            magic("problem with cell")
            return UITableViewCell()
        }
        let contact = self.contacts[indexPath.row]
        cell.configureCell(contact: contact)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = self.contacts[(indexPath as NSIndexPath).row]
        guard let user = self.user else {magic("user error");return}
        
        //predicate - if oppositeContactIds containts contactId that is equal to selectedContact.id, and if chatroom is not custom
        let predicate = NSPredicate(format: "ANY oppositeContactIds.contactId ==[c] %@ AND isCustom = %@", selectedContact.id, false as CVarArg)
        let chatrm = user.getRealm().objects(Chatroom.self).filter(predicate).first
        self.performSegue(withIdentifier: "ContactsChattoSegue", sender: chatrm)
    }

    //--------------------------------------------------------------------
    // MARK: - -Table view editing-

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if  !self.isEditing {
            return UITableViewCellEditingStyle.none;
        } else {
            return UITableViewCellEditingStyle.delete
        }
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let contact = self.contacts[sourceIndexPath.row]
        self.contacts.remove(at: sourceIndexPath.row);
        self.contacts.insert(contact, at: destinationIndexPath.row)
    }
    
    //MARK: Delete Contact TableView
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let contactToDelete = self.contacts[indexPath.row]
            self.deleteContactPrompt(contactToDelete)
        }
    }
    
    //MARK: View for header
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerFrame = tableView.frame
        let headerView:UIView = UIView(frame: CGRect(x:0,y: 0,width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.backgroundColor = UIColor.clear
        
        //SEARCH FRIENDS BUTTON
        let searchContactBttn:UIButton = UIButton.init(type: .system)
        searchContactBttn.setTitle(" Search Friends", for: UIControlState.normal)
        searchContactBttn.titleLabel?.tintColor = UIColor.blue
        searchContactBttn.setImage(UIImage(named: "searchUsers"), for: UIControlState.normal)
        searchContactBttn.titleLabel!.font = UIFont.systemFont(ofSize: 12.0)
        searchContactBttn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        searchContactBttn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        searchContactBttn.isEnabled = true
        searchContactBttn.backgroundColor = UIColor.white
        searchContactBttn.addTarget(self, action: #selector(self.onBarButtonSearch), for: .touchUpInside)
        headerView.addSubview(searchContactBttn)
    
        //Section Title Label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.lightGray
        titleLabel.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        
        if self.contacts.count == 0 {
            titleLabel.text = "No Contacts Yet"
        } else {
            titleLabel.text = "Contacts"
        }
    
        headerView.addSubview(titleLabel)
        
        searchContactBttn.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var viewsDict = Dictionary <String, UIView>()
        viewsDict["headerView"] = headerView
        viewsDict["searchContactBttn"] = searchContactBttn
        viewsDict["titleLabel"] = titleLabel
        
        //Search Contact Button Horizontal Constraint
        headerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[searchContactBttn(==headerView)]|", options: [], metrics: nil, views: viewsDict))
        //Search Contact Button Horizontal Constraint
        headerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[titleLabel(==headerView)]|", options: [], metrics: nil, views: viewsDict))
        
        //Search and Add Contact Button Vertical Constraints
        headerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-40-[searchContactBttn(30)]-10-[titleLabel(20)]-0-|", options: [], metrics: nil, views: viewsDict))
        return headerView
    }

    
    //------------------------------------------------------------------------------
    // MARK: - Delete contact
    
    func deleteContactFromSocket(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo, let id = userInfo["friendToDeleteId"] as? String {
            self.deleteContact(id, fromPrompt: false)
        }
    }
    
    func deleteContactFromBlock(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo, let id = userInfo["friendToBlockedId"] as? String {
            self.deleteContact(id, fromPrompt: true) // fromPrompt 'true' because we want to delete contact in server
        }
    }

    private func deleteContactPrompt(_ contactToDelete:Contact) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This contact will be deleted and all messages with this contact will be deleted!", preferredStyle: .actionSheet)
        
        // delete chatroom
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action: UIAlertAction) -> Void in
            self.deleteContact(contactToDelete.id, fromPrompt: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
    Delete contact from PROMPT or from SOCKET
    */
    func deleteContact(_ contactToDeleteId:String, fromPrompt:Bool) {
        
        guard let user = self.user else {magic("user error");return}
        
        //Find Chatroom Id
        var chatroomId = ""
        for chatroom in user.chatrooms {
            for oppositeContactId in chatroom.oppositeContactIds {
                if oppositeContactId.contactId == contactToDeleteId {
                    chatroomId = chatroom.id
                    break
                }
            }
        }
        guard chatroomId != "" else {magic("no chatroomId");return}
            if let contactToDel:Contact = user.getRealm().object(ofType: Contact.self, forPrimaryKey: contactToDeleteId), let chatroomToDelete:Chatroom = user.getRealm().object(ofType: Chatroom.self, forPrimaryKey: chatroomId) {
                if fromPrompt {
                    SocketIOManager.sharedInstance.deleteContact(contactToDeleteId, chatroomId, contactCallback: { [weak self] (deletedContactData) in
                        self?.deleteContactChatroomMessagesFromRealm(user: user, contactToDel: contactToDel, chatroomToDelete: chatroomToDelete)
                    })
                } else {
                    self.deleteContactChatroomMessagesFromRealm(user: user, contactToDel: contactToDel, chatroomToDelete: chatroomToDelete)
                }
            } else {
                self.alert("Failed to delete contact", title: "Failure")
            }
    }
    
    private func deleteContactChatroomMessagesFromRealm(user:User, contactToDel:Contact, chatroomToDelete:Chatroom) {
            print("\n\n==============DELETED CONTACT==============")
            print("Contact to Delete: \(contactToDel)")
            print("Chatroom to Delete: \(chatroomToDelete)")
            print("Messages to Delete: \(chatroomToDelete.messages)")
            print("==============================================\n")
        
            //Refresh
            let c = self.contacts.filter { (contact) -> Bool in
                return contact.id != contactToDel.id
            }
            self.contacts = c

            user.write({
                user.getRealm().delete(contactToDel)                                ////Delete Contact
                chatroomToDelete.getRealm().delete(chatroomToDelete.messages)       ////Delete All Messages
                user.getRealm().delete(chatroomToDelete)                            ////Delete Chatroom
            })
        
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadChatrooms"), object: nil)
            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
            self.refreshBadge()
    }
    
    //--------------------------------------------------------------------
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.tabBarController?.tabBar.isHidden = true
        //Chatto
        if segue.identifier == "ContactsChattoSegue" {
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

        if segue.identifier == "incomeRequestSegue" {
            if let nav = segue.destination as? UINavigationController,
                let vc = nav.topViewController as? IncomeRequestsTVC {
                vc.incomeRequests = self.requests
            }
        }
        if segue.identifier == "accountSegue" {
              if let vc = segue.destination as? AccountVC {
                vc.avatarImage = self.viewAvatar.image
            }
        }

    }
}

//--------------------------------------------------------------------
//--------------------------------------------------------------------
// MARK: - BackButtonEditable protocol

extension ContactsTVC: BackButtonEditable {
    func backButton(badge: String) {
        let backButton = UIBarButtonItem()
        backButton.title = badge
        self.navigationItem.backBarButtonItem = backButton
    }
}

