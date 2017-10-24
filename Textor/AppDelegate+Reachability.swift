//
//  AppDelegate+Reachability.swift
//  Textor
//
//  Created by eugene golovanov on 2/8/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import ReachabilitySwift

extension AppDelegate {

    //---------------------------------------------------------------------------------
    //MARK: - Reachability
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: BarType.showConnecting.rawValue), object: nil, userInfo: ["type" : CONNECTING_MSG_CONNECTING]))
            }
            reachability?.whenUnreachable = { reachability in
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: BarType.showConnecting.rawValue), object: nil, userInfo: ["type" : CONNECTING_MSG_WAITING_NET]))
            }
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            print("Problem with reachability notifier")
            return
        }
    }

}
