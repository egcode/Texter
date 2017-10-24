//
//  AppDelegate.swift
//  Textor
//
//  Created by eugene golovanov on 8/9/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import RealmSwift
import ReachabilitySwift
import GoogleSignIn
import FacebookLogin
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Overwrite realm data if migration needed
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        Realm.Configuration.defaultConfiguration = config

        //Reachability
        self.setupReachability(URL_API, useClosures: true)
        self.startNotifier()
        
        //Google
        GIDSignIn.sharedInstance().clientID = "YOUR-GOOGLE-ID.apps.googleusercontent.com"
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        //Facebook Stuff
        FBSDKAppEvents.activateApp()
    }
    
    //---------------------------------------------------------------------------------
    //MARK: - Google register
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if String(describing: url).hasPrefix("fb") {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }


}

