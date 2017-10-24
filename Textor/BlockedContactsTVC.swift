//
//  BlockedContactsTVC.swift
//  Textor
//
//  Created by Eugene Golovanov on 6/10/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class BlockedContactsTVC: UITableViewController {

    var contacts = [Contact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SocketIOManager.sharedInstance.getAllBlockedContacts { (blockedContactsData) in
            let _ = blockedContactsData.map({self.contacts.append(Contact(data: $0))})
            self.updateEmptyStateView()
            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
        }
    }
    
    // -------------------------------------------------
    // MARK: - Empty state

    func updateEmptyStateView() {
        if self.contacts.count != 0 {
            self.tableView.backgroundView = nil
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            messageLabel.text = "You have no blocked contacts"
            messageLabel.textColor = UIColor.lightGray
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont.systemFont(ofSize: 18)
            messageLabel.sizeToFit()
            messageLabel.center = self.tableView.center
            self.tableView.backgroundView = messageLabel
        }
    }

    // -------------------------------------------------
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.contacts.count > 0 {
            return self.contacts.count
        } else {
            self.updateEmptyStateView()
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "blockedCell", for: indexPath) as? BlockedContactsCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configureCell(contact: self.contacts[indexPath.row])
        return cell
    }
 
    // -------------------------------------------------
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension BlockedContactsTVC: UnblockContactsDelegate {
    func unblockContact(contact: Contact) {
        SocketIOManager.sharedInstance.unblockContact(contact.id) { (unblockedContactId) in
            if contact.id == unblockedContactId {
                self.contacts = self.contacts.filter({$0.id != unblockedContactId})
                self.updateEmptyStateView()
                self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
            }
        }
    }
}
