//
//  API.swift
//  Textor
//
//  Created by eugene golovanov on 8/9/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation

open class APIResponse: CustomDebugStringConvertible {
    open var code:Int
    open var success:Bool
    open var rawData:AnyObject?
    open var data:Dictionary<String,AnyObject>?
    open var dataArray:Array<Dictionary<String, AnyObject>>?
    open var multiDataArray:Array<Array<Dictionary<String, AnyObject>>>?
    open var dataNum:Int?
    open var dataString:String?
    open var error:NSError?
    open let request:URLRequest?
    open let duration:TimeInterval
    open var token:String?
    open var id:String?
    
    init(request:URLRequest?, duration:TimeInterval, payload:AnyObject?, error:NSError?){
        self.code = -1
        self.success = false
        self.data = nil
        self.error = nil
        self.request = request
        self.duration = duration
        self.token = nil
        self.id = nil
        
        if(error != nil){
            self.error = error
        }
        else if let obj = payload {
            self.rawData = obj
            if let dict = obj as? Dictionary<String,AnyObject> {
                
                if let data = dict["data"] as? Dictionary<String, AnyObject> {
                    self.data = data
                } else if let data = dict["data"] as? Array<Dictionary<String, AnyObject>> {
                    self.dataArray = data
                } else if let data = dict["data"] as? Array<Array<Dictionary<String, AnyObject>>> {
                    self.multiDataArray = data
                } else if let data = dict["data"] as? String {
                    self.dataString = data
                } else if let data = dict["data"] as? [Int] {
                    if data.count > 0{
                        self.dataNum = data[0]
                    }
                }
            }
        }
    }
    
    open var debugDescription: String {
        let icon = self.success ? "✅" : "🚫"
        var descr = "\(icon) <APIResponse"
        
        if let r = self.request, let u = r.url, let m = r.httpMethod {
            descr += " \(m) \(u)"
        }
        
        descr += " success=\(self.success) code=\(self.code)"
        
        if let err = self.error {
            descr += " error=\(err)"
        }
        
        let d = NSString(format: "%.2f", self.duration)
        return descr + " duration=\(d)s>"
    }
}


open class API {
    
    enum Crud:String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    //Get
    open class func get(_ url:AnyObject, userToken:String?, completed: @escaping (_ response:APIResponse) -> Void) {
        self.createURLRequest(url, method: .get, userToken: userToken, payload: nil, completed: completed)
    }
    
    //Post
    open class func post(_ url:AnyObject, payload:[String:AnyObject]? = nil, userToken:String?, completed: @escaping (_ response:APIResponse) -> Void) {
        self.createURLRequest(url, method: .post, userToken: userToken, payload: payload, completed: completed)
    }
    
    //Put
    open class func put(_ url:AnyObject, payload:[String:AnyObject]? = nil, userToken:String?, completed: @escaping (_ response:APIResponse) -> Void) {
        self.createURLRequest(url, method: .put, userToken: userToken, payload: payload, completed: completed)
    }
    
    //Delete
    open class func delete(_ url:AnyObject, payload:[String:AnyObject]? = nil, userToken:String?, completed: @escaping (_ response:APIResponse) -> Void) {
        self.createURLRequest(url, method: .delete, userToken: userToken, payload: payload, completed: completed)
    }
    
    fileprivate class func createURLRequest(_ u:AnyObject, method: Crud, userToken:String?, payload:[String:AnyObject]? = nil, completed: @escaping (_ response:APIResponse) -> Void) -> Void {
        
        let startTime = Date()
        
        let url:URL
        
        if let ur = u as? URL {
            url = ur
        } else if let ur = u as? String, let uu = URL(string: ur) {
            url = uu
        } else {
            completed(APIResponse(request: nil, duration: 0, payload: nil, error: nil))
            return
        }
        let request = NSMutableURLRequest(url: url)
        
        
        //If Token
        if let token = userToken  {
            print("\nAPI \(method) \(url) with token \(token)")
            request.addValue(token, forHTTPHeaderField: "x-access-token")
        }
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30
        
        if method != .get {
            if let pl = payload {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: pl, options: JSONSerialization.WritingOptions())
                } catch let error as NSError {
                    print("Error in request post: \(error)")
                    request.httpBody = nil
                } catch {
                    print("Catch all error: \(error)")
                }
            }
        }
        
        #if HOME
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        #else
            let delegate = URLSessionPinningDelegate()
            let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        #endif
        
        session.dataTask(with: request as URLRequest) {data, response, error in
            //in case of error
            if error != nil {
                print(error ?? "shit")
                completed(APIResponse(request: request as URLRequest, duration: Date().timeIntervalSince(startTime), payload: nil, error: error as NSError?))
                return
            } else {
                guard let httpResponse = response as? HTTPURLResponse else{ print("response error"); return }
                guard let data = data else { print("error getting data"); return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    var obj = [String:AnyObject]()
                    obj["data"] = json as AnyObject?
                //////////Response//////////
                    let apiResponse = APIResponse(request: request as URLRequest, duration: Date().timeIntervalSince(startTime), payload: obj as AnyObject?, error: error as NSError?)
                    //token if exists
                    apiResponse.code = httpResponse.statusCode
                    apiResponse.success = API.statusSuccessChecker(httpResponse.statusCode)
                    if let token = httpResponse.allHeaderFields["token"] as? String {
                        apiResponse.token = token
                    }
                    //id if exists
                    if let id = httpResponse.allHeaderFields["_id"] as? String {
                        apiResponse.id = decrypt(string: id)
                    }
                    completed(apiResponse)
                /////////////////////////////
                } catch {
                    print("Json Error:\(error)")
                    let resp = APIResponse(request: request as URLRequest, duration: Date().timeIntervalSince(startTime), payload: nil, error: nil)
                    if httpResponse.statusCode == 204 {
                        print("Json is empty but response is OK")
                        resp.success = true
                        resp.code = 204
                    }
                    completed(resp)
                }
            }
        }.resume()
    }
    
    open class func statusSuccessChecker(_ code:Int) -> Bool {
        var success = false
        
        if code == 200 {
            print("SUCCESS.........200")
            success = true
        }
        else if code == 201 {
            print("SUCCESS.........201")
            success = true
        }
        else if code == 202 {
            print("SUCCESS.........202")
            success = true
        }
        else if code == 204 {
            print("SUCCESS BUT NOTHING TO SEND.........204")
            success = true
        }
            
        else if code == 500 {
            print("SERVER ERROR.........500")
        }
            
        else if code == 400 {
            print("VALIDATION ERROR.........400")
        }
            
        else if code == 401 {
            print("UNAUTHORIZED ERROR.........401")
        }
            
        else if code == 412 {
            print("PRECONDITIONAL FAIL ERROR.........412")
        }
            
        else  {
            print("UNDEFINED RESPONSE")
        }
        
        return success
    }
        
}

public func decrypt(string:String) -> String {
    // Load only what's necessary
    let AES = CryptoJS.AES()
    
    // AES decryption
    let decrypted = AES.decrypt(string, secretKey: KEY_CRYPTOJS)
    
    return decrypted
}

