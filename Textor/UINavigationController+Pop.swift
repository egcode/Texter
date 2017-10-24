//
//  UINavigationController+Pop.swift
//  Textor
//
//  Created by eugene golovanov on 1/15/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

extension UINavigationController {
    func pop(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool) {
        _ = self.popToRootViewController(animated: animated)
    }
}
