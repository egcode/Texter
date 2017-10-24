//
//  DynamicNavBar.swift
//  Textor
//
//  Created by eugene golovanov on 3/28/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

enum BarType : String {
    case showConnecting = "showConnectingBar"
    case showDefault = "showDefaultBar"
}

protocol DynamiNavBarProtocol {
    func showDefaultBar()//Declare method for override
}

extension DynamiNavBarProtocol where Self: UIViewController {
    //-----------------------------------------------------------------------------------
    // MARK: - Connection check
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BarType.showConnecting.rawValue), object: nil, queue: nil) { [weak self] (notification) in
            self?.showSpinnerBar(notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: BarType.showDefault.rawValue), object: nil, queue: nil) { [weak self] (notification) in
            self?.showDefaultBar()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "alert"), object: nil, queue: nil) { [weak self] (notification) in
            self?.alert(notification)
        }
    }
    
    
    func connectionCheck() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            magic("Something wrong with delegate")
            return
        }
        //Connect If not connected
        SocketIOManager.sharedInstance.checkConnection { [weak self] (connected) in
            guard let sSelf = self else { magic("no self"); return }
            guard let navBar = sSelf.navigationController?.navigationBar as? SpinnerNavigationBar else{ magic("navbar err"); return }
            if !connected {
                if appDelegate.reachability?.isReachable == true  {
                    navBar.showSpinnerLabel(CONNECTING_MSG_CONNECTING, navigationItem: sSelf.navigationItem)
                } else {
                    navBar.showSpinnerLabel(CONNECTING_MSG_WAITING_NET, navigationItem: sSelf.navigationItem)
                }
            } else {
                sSelf.showDefaultBar()
            }
        }
    }
    
    //-----------------------------------------------------------------------------------
    // MARK: - Connection Label
    
    func showSpinnerBar(_ notification: Notification) {
        guard let navBar = self.navigationController?.navigationBar as? SpinnerNavigationBar else{magic("navbar err");return}
        if let mode = (notification as NSNotification).userInfo, let type = mode["type"] as? String {
            GCD.mainThread {
                //String from notification
                navBar.showSpinnerLabel(type, navigationItem: self.navigationItem)
            }
        }
    }
    
    func showDefaultBar() {
        guard let navBar = self.navigationController?.navigationBar as? SpinnerNavigationBar else{magic("navbar err");return}
        GCD.mainThread {
            navBar.showDefaultLabel(self.navigationItem)
        }
    }
    
    //-----------------------------------------------------------------------------------
    // MARK: - alert
    
    func alert(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo, let alertTitle = userInfo["alertTitle"] as? String, let alertMessage = userInfo["alertMessage"] as? String {
            self.alert(alertMessage, title: alertTitle)
        }
    }
}
