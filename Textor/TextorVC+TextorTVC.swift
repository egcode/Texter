//
//  TextorVC+TextorTVC.swift
//  Textor
//
//  Created by eugene golovanov on 9/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

class TextorVC: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

class TextorTVC: UITableViewController, DynamiNavBarProtocol {
    
    //-----------------------------------------------------------------------------------
    // MARK: - View Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.connectionCheck()
    }
    
    //-----------------------------------------------------------------------------------
    // MARK: - init and deinit

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.registerNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
