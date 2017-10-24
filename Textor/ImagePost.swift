//
//  ImagePost.swift
//  S3AlamofireUpload
//
//  Created by eugene golovanov on 10/11/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//


import Alamofire
import SwiftyJSON


class ImagePost {
    
    static func getPresignedURL(image: UIImage,folderName:String, completionHandler: @escaping (_ success:Bool, _ postURL: String?, _ getURL: String?) -> ()) {
        let request = Alamofire.request(GET_TOKEN_URL, method: .get ,headers: ["foldername":folderName])
        request.validate()
        request.responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    if let postURL = json["postURL"].string, let getURL = json["getURL"].string {
                        completionHandler(true, postURL, getURL)
                    }
                }
                completionHandler(false, nil, nil)
            case .failure (let error):
                print("ERR \(response) \(error)")
                completionHandler(false, nil, nil)
            }
        }
    }

}
