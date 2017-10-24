//
//  ImageUtils.swift
//  Textor
//
//  Created by eugene golovanov on 10/25/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit
import Alamofire

class ImageUtils {
    
    class func resizeImage(image: UIImage, newMax: CGFloat) -> UIImage? {
        
        let origSize = image.size
        let maxSide = max(origSize.width, origSize.height)
        var scale:CGFloat = 1
        let coef = maxSide/newMax;
        if (coef > 1) {
            scale =  1/coef;
        }
        let newSize = CGSize(width: origSize.width*scale, height: origSize.height*scale)
        
        UIGraphicsBeginImageContext(CGSize(width: newSize.width, height: newSize.height))
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func downloadAvatar(url:String, request:Request?, completion: @escaping (_ success:Bool,_ progress:Double, _ image:UIImage?) -> Void) {
        weak var request = request
        request = Alamofire.request(url)
            .downloadProgress(closure: { (progress) in
                print("Progress: \(progress.fractionCompleted)")
                completion(false, progress.fractionCompleted, nil)
            })
            .responseData { response in
                guard let data = response.result.value else {
                    magic("no avatar data")
                    completion(false,1.0, nil)// Failed download
                    return
                }
                if let image = UIImage(data: data) {
                    completion(true,1.0, image)// Success download
                }
        }
    }

    
}
