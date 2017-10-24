//
//  InitialVC.swift
//  Textor
//
//  Created by eugene golovanov on 8/9/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {
    
    fileprivate var rootViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.startupInit {
            InitialVC.connectListenSocket()
        }
    }
    
    /**
     Everytime we login or start the app we hit this function.
     we start and listen our main connection hangler: socket.on("connect")
     
     - if we 'needLoginTransition' we transition with animation from LoginVC
     - 'refreshConnect' refreshes contact every time we reconnect our socket
     */
    class func connectListenSocket() {
        if DataManager.model.isLoggedIn {
            SocketIOManager.sharedInstance.startSocketConnection({ (connected) in
                if connected {
                    if DataManager.needLoginTransition {
                        InitialVC.showMain()
                    } else {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshConnect"), object: nil)
                    }
                } else {
                    User.logout({ (success) in
                    })
                    InitialVC.showLogin()
                }
            })
        } else {
            InitialVC.showLogin()
        }
    }
    
    class func showLogin() {
        let sb = UIStoryboard(name: "Login", bundle: nil)
        InitialVC.animateTransition(sb)
        DataManager.needLoginTransition = true
    }
    
    class func showMain() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        InitialVC.animateTransition(sb)
        DataManager.needLoginTransition = false
    }
    
    class func animateTransition(_ storyboard:UIStoryboard) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        guard let vc = storyboard.instantiateInitialViewController() else {
            return
        }
        let snapshot:UIView = (appDelegate.window?.snapshotView(afterScreenUpdates: true))!
        vc.view.addSubview(snapshot);
        
        appDelegate.window?.rootViewController = vc// asign
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.1);
            }, completion: {
                (value: Bool) in
                snapshot.removeFromSuperview();
        });
    }
}
