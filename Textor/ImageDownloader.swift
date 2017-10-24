//
//  ImageDownloader.swift
//  Textor
//
//  Created by eugene golovanov on 10/31/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions
import Alamofire


class ImageDownloader: AsynchronousOperation {

    weak var timer = Timer()
    var count:Int = DOWNLOAD_WAIT
    
    let message: TXPhotoMessageModel
    let url: String
    weak var request: Alamofire.Request?
    let networkOperationCompletionHandler: (_ responseObject: Any?, _ downloadedImage: UIImage?, _ error: Error?) -> ()
    
    init(message: TXPhotoMessageModel, url:String, networkOperationCompletionHandler: @escaping (_ responseObject: Any?, _ downloadedImage: UIImage?, _ error: Error?) -> ()) {
        self.message = message
        self.url = url
        self.networkOperationCompletionHandler = networkOperationCompletionHandler

        super.init()
    }
    
    //Main is the method you override in NSOperation subclasses to actually perform work.
    override func main() {

        GCD.mainThread {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: true)
        }
        
        ///////////
        //Download Image to memory
        request = Alamofire.request(self.url)
            .downloadProgress(closure: { (progress) in
                print("Progress: \(progress.fractionCompleted)")
                self.message.statusExtended = .getting
                self.message.progress = progress.fractionCompleted
                RefreshManager.sharedRM.updateMessage(self.message)

                self.count = DOWNLOAD_WAIT
                
            })
            .responseData { response in

                self.timer?.invalidate()
                
                guard let data = response.result.value else {
                    self.networkOperationCompletionHandler(nil, nil, nil)
                    self.completeOperation()//COMPLETE
                    return
                }
                if let image = UIImage(data: data), let scaledImage = ImageUtils.resizeImage(image: image,
                                                                                             newMax: IMAGE_ORIG_MAX) {
                    self.networkOperationCompletionHandler(response.result.value, scaledImage, response.result.error)
                    self.completeOperation()//COMPLETE
                }
        }
        //End of Download Image to memory
        /////////////
    }
    
    //Canceling the request, in case we need it
    override func cancel() {
        request?.cancel()
        super.cancel()
    }
    
    func timerFunc() {
        self.count -= 1
        print("COUNTER: \(count)")
        if self.count == 0 {
            self.timer?.invalidate()
            self.networkOperationCompletionHandler(nil, nil, nil)
            self.completeOperation()//COMPLETE
            self.cancel()
        }
    }
}


