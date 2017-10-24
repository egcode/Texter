//
//  NSLock+withCriticalScope.swift
//  Textor
//
//  Created by eugene golovanov on 11/1/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation

extension NSLock {
    
    /// Perform closure within lock.
    ///
    /// An extension to `NSLock` to simplify executing critical code.
    ///
    /// - parameter block: The closure to be performed.
    
    func withCriticalScope<T>( block: (Void) -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
