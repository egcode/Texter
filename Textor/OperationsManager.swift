//
//  OperationsManager.swift
//  Textor
//
//  Created by eugene golovanov on 11/1/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation

class OperationsManager {
    
    static let sharedOM = OperationsManager()

    lazy var downloadsInProgress = [String:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var uploadsInProgress = [String:Operation]()
    lazy var uploadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Upload queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    
}
