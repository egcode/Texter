//
//  DeviceManager.swift
//  Textor
//
//  Created by eugene golovanov on 12/28/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import UserNotifications

class DeviceManager {
    
    //---------------------------------------------------------------------------------
    //MARK: - Apple Register

    class func registerPushNotifications() {
        //Register Push Notifications
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                if error == nil && granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
            
            //register for push, but only if not on simulator for < ios 8 for ios 9 we need to add (TARGET_OS_SIMULATOR != 1) ||
            //it'll warn if you have the simulator selected in devices when running, ignore it.
            if ( TARGET_IPHONE_SIMULATOR == 0 || TARGET_OS_SIMULATOR != 1) {
                let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound])
                let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    class func unregisterPushNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    //---------------------------------------------------------------------------------
    //MARK: - Backend Register

    //POST /devices
    class func registerDeviceBackend(token:String, deviceUUID:String, userId:String, deviceToken:String, completion: @escaping (_ success:Bool) -> Void) {
        
        let payload:[String:AnyObject] = ["user_id"         : userId as AnyObject,
                                          "device_platform" : "iOS" as AnyObject,
                                          "device_guid"     : deviceUUID as AnyObject,
                                          "device_token"    : deviceToken as AnyObject]

        API.post(URL_DEVICES as AnyObject, payload: payload, userToken: token) { (response) in
            print("---------------------------Create device response:--------------------------------")
            print(response)
            print("----------------------------------------------------------------------------------")
            
            if response.success == true {
                print("Create device SUCCESS")
                completion(true)
            } else {
                print("Create device Failure")
                completion(false)
            }
        }
    }
    
    //DELETE /devices/:guid
    class func unregisterDeviceBackend(token:String) {
        
        API.delete(URL_DEVICES_ID as AnyObject , userToken: token) { (response) in
            print("---------------------------Delete device response:--------------------------------")
            print(response)
            print("----------------------------------------------------------------------------------")
            
            if response.success == true {
                print("Delete Device SUCCESS")
            } else {
                print("Delete Device Failure")
            }
        }
    }

}
