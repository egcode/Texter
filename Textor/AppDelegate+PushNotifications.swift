//
//  AppDelegate+PushNotifications.swift
//  Textor
//
//  Created by eugene golovanov on 2/5/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        guard let token = DataManager.model.currentUser?.token else {magic("no token");return}
        guard let userId = DataManager.model.currentUser?.id else {magic("no user Id");return}
        
        //POST /devices
        DeviceManager.registerDeviceBackend(token: token, deviceUUID: DEVICE_UUID, userId: userId, deviceToken: deviceTokenString) { (success) in
            if success == true {
                print("Successfully registered Device: \(deviceTokenString)")
            }
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let info = userInfo
        
        if let type = info["type"] as? String {
            if type == "message", let chatroomId = info["chatroomId"] {
                print("chatroom id: \(chatroomId)")
            }
        }
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let body = alert["body"] as? NSString, let title = alert["title"] as? NSString {
                    print("body:\(body) \ntitle:\(title)")
                }
            }
        }
        
    }

}
