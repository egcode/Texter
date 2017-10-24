//
//  IncomeRequestsTVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/21/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class IncomeRequestsTVC: UITableViewController {

    //----------------------------------------------------------------------
    // MARK: - Properties
    var incomeRequests = [Contact]()
    
    //----------------------------------------------------------------------
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Friend Requests"
    }
    
    //------------------------------------------------------------------------------
    //MARK: - init deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(IncomeRequestsTVC.removeOperatedRequests), name: NSNotification.Name(rawValue: "removeOperatedRequests"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //--------------------------------------------------------------------------------
    // MARK: - Refreshers
    
    func removeOperatedRequests(_ notification: Notification) {
        if let contactId = (notification as NSNotification).userInfo, let id = contactId["id"] as? String {
            for (index, contact) in self.incomeRequests.enumerated() {
                if id == contact.id {
                    self.incomeRequests.remove(at: index)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    
    //--------------------------------------------------------------------------------
    // MARK: - Actions
    
    @IBAction func onCancelBarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //--------------------------------------------------------------------------------
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.incomeRequests.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "incomeRequestCell") as? IncomeRequestsCell else {
            magic("problem with IncomeRequestsCell")
            return UITableViewCell()
        }
        let req = self.incomeRequests[(indexPath as NSIndexPath).row]
        cell.configureCell(contact: req)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = self.incomeRequests[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "incomeRequestSegue", sender: selectedContact)
    }
    
    
    //-----------------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "incomeRequestSegue" {
            if let vc = segue.destination as? IncomeRequestVC {
                vc.contact = sender as? Contact
            }
            
        }
    }
    
}
