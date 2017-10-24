//
//  DataModel.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import RealmSwift

class DataModel: Object {

    dynamic var currentUser: User?
    
    var isLoggedIn: Bool {
        get {
            return self.currentUser != nil
        }
    }
}



