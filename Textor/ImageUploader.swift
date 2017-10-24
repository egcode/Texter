//
//  ImageUploader.swift
//  Textor
//
//  Created by eugene golovanov on 11/26/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import Chatto
import ChattoAdditions
import Alamofire


class ImageUploader: AsynchronousOperation {
    
    weak var timer = Timer()
    var count:Int = UPLOAD_WAIT
    
    let message: TXPhotoMessageModel
    let messageRealm: Message
    
    weak var request: Alamofire.Request?
    let networkOperationCompletionHandler: (_ message: TXMessageModelProtocol, _ success:Bool) -> ()
    
    let chatroomId: String
    let imageToUpload: UIImage

    
    init(message: TXPhotoMessageModel, messageRealm: Message, chatroomId:String, imageToUpload:UIImage, networkOperationCompletionHandler: @escaping ( _ message: TXMessageModelProtocol, _ success:Bool) -> ()) {
        self.message = message
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
        
        self.chatroomId = chatroomId
        self.imageToUpload = imageToUpload
        self.messageRealm = messageRealm
        
        super.init()
    }
    
    //Main is the method you override in NSOperation subclasses to actually perform work.
    override func main() {
        
        GCD.mainThread {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerFunc), userInfo: nil, repeats: true)
        }
        
        ImagePost.getPresignedURL(image: self.imageToUpload, folderName: self.chatroomId) { (success, postURL, getURL) in
            guard success else {
                print("Upload FAIL")
                return
            }
            print("Upload SUCCESS with url:\(postURL)")
            guard let presignedURL = postURL else {magic("no presig url");return}
            guard let imageURL = getURL else {magic("no get url");return}
            
            /////Start UPLOAD\\\\\\
            if let imageData = UIImageJPEGRepresentation(self.imageToUpload, 0.3) {
                print("Uploading! Hang in there...")
                
                self.message.progress = 0// zero OUT
                self.message.statusExtended = .sending
                RefreshManager.sharedRM.updateMessage(self.message)
                
                self.request = Alamofire.upload(imageData, to: presignedURL, method: .put, headers: ["Content-Type":"image/jpeg"])
                    .uploadProgress { progress in // main queue by default

                        self.message.progress = progress.fractionCompleted
                        print("++\(progress.fractionCompleted)")
                        RefreshManager.sharedRM.updateMessage(self.message)

                        self.count = UPLOAD_WAIT

                    }
                    .responseJSON { response in
                        if response.response?.statusCode == 200 {
                            print("\nUpload SUCCESS\n")
                            self.message.statusExtended = .success
                            self.message.progress = 1.0
                            
                            self.timer?.invalidate()
                            
                            print("++++++++++++++++++++++++++++++++++++++++++++++++")
                            print(imageURL)
                            print("++++++++++++++++++++++++++++++++++++++++++++++++")
                            
                            DataManager.model.currentUser?.write({
                                self.messageRealm.photoUrl = imageURL
                            })
                            
                            // COMPLETE
                            self.networkOperationCompletionHandler(self.message, true)
                            self.completeOperation()//COMPLETE
                            
                        } else {
                            print("\nUpload FAIL\n")
                            self.message.statusExtended = .failed
                            self.message.progress = 0
                            RefreshManager.sharedRM.updateMessage(self.message)
                            OperationsManager.sharedOM.uploadsInProgress[self.message.uid] = nil
                            
                            DataManager.model.currentUser?.write({
                                self.messageRealm.statusDB = MESSAGE_STATUS_NOT_SENT
                            })

                        }
                }
            }
            ////End of UPLOAD\\\
        }
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
            self.networkOperationCompletionHandler(self.message, false)
            self.completeOperation()//COMPLETE
            self.cancel()
            
            DataManager.model.currentUser?.write({
                self.messageRealm.statusDB = MESSAGE_STATUS_NOT_SENT
            })

        }
    }

    
}

