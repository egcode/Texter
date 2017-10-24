//
//  GCD.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation

public class GCD {
    
    public class func mainThread(block:@escaping () -> Void) {
        DispatchQueue.main.async {block()}
    }
    
    public class func mainThreadDelayed(delay: TimeInterval, block:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {block()}
    }
    
    public class func backgroundThread(block:@escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {block()}
    }
    
    public class func backgroundThreadDelayed(delay: TimeInterval, block:@escaping () -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {block()}

    }

}
