//
//  SearchContactsTVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/18/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class SearchContactsTVC: UITableViewController, UISearchResultsUpdating {

    //----------------------------------------------------------------------
    // MARK: - Properties

    var contacts = [Contact]()
    let resultSearchController = UISearchController(searchResultsController: nil)

    //----------------------------------------------------------------------
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup search controller
        self.resultSearchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.placeholder = "Type email or name"
        self.resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        //add Search Bar to the TableView
        self.tableView.tableHeaderView = resultSearchController.searchBar
    }
    
    //------------------------------------------------------------------------------
    // MARK: - -UISearchResultsUpdating-
    func updateSearchResults(for searchController: UISearchController) {
        self.contacts.removeAll()
        self.tableView.reloadData()
        guard let searchText = searchController.searchBar.text else {magic("\nsearch bar is empty\n");return}
//        searchController.searchBar.text!.lowercased()
        self.searchFriends(with: searchText)
    }
    
    func searchFriends(with searchText:String) {

        guard let token = DataManager.model.currentUser?.token else {magic("token problem");return}
        let path = URL_USERS + "?q=" + searchText.lowercased()
        print("searchText: \(path)")
        
        API.get(path as AnyObject, userToken: token) { (response) in
            if response.code == 200 && response.success == true {
                print("==============")
                print(response)
                print("==============")
                if let dataArray = response.dataArray {
                    for data in dataArray {
                        let contact = Contact(data: data)
                        GCD.mainThread {
                            if let user = DataManager.model.currentUser {
                                if user.contacts.contains(where: {$0.id == contact.id}) == false && user.id != contact.id {
                                    self.contacts.append(contact)
                                }
                            }
                        }
                    }
                }
                GCD.mainThread(block: {
                    self.tableView.reloadData()
                })
                
            } else {
                
            }
        }
    }

    //------------------------------------------------------------------------------
    // MARK: - Action
    
    @IBAction func onDoneBarButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //--------------------------------------------------------------------------------
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchContactsCell") as? SeachContactsCell else {
            magic("problem with SeachContactsCell")
            return UITableViewCell()
        }
        let contact = self.contacts[(indexPath as NSIndexPath).row]
        cell.configureCell(contact: contact)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = self.contacts[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "requestSegue", sender: selectedContact)
    }
    
    //-----------------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "requestSegue" {
            if let vc = segue.destination as? RequestOutVC {
                vc.contact = sender as? Contact
            }
            
        }
    }
}
