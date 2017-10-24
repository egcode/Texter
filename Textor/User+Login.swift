//
//  User+Login.swift
//  Textor
//
//  Created by eugene golovanov on 2/11/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import Foundation
import RealmSwift
import GoogleSignIn
import FacebookLogin
import FBSDKCoreKit


extension User {
    class func login(_ email:String, password:String, completion: @escaping (_ success: Bool) -> Void) {
        
        let paramsDictionary = ["email":email, "password":password]
        
        //LOGIN  POST /users/login
        API.post(URL_LOGIN as AnyObject, payload: paramsDictionary as [String : AnyObject]?, userToken: nil, completed: { (response) in
            
            print("----------Login Response:------------------")
            print(response)
            print("-------------------------------------------")
            
            if response.success == true {
                if let token = response.token, let id = response.id {
                    print("token: \(token)")
                    print("id: \(id)")
                    print("email: \(email)")
                    
                    
                    GCD.mainThread(block: {
                        self.write {
                            let user = DataManager.getRealm().create(User.self, value: ["id": id], update: true)
                            user.token = token
                            user.email = email
                            user.firstName = "first"
                            user.lastName = "last"
                            DataManager.model.currentUser = user
                        }
                        completion(true)
                    })
                    
                }
            } else {
                completion(false)
            }
        })
    }
    
    class func signup(_ email:String, password:String, completion: @escaping (_ success: Bool) -> Void) {
        
        let paramsDictionary = ["email":email, "password":password]
        
        //SIGNUP   POST /users
        API.post(URL_USERS as AnyObject, payload: paramsDictionary as [String : AnyObject]?, userToken: nil, completed: { (response) in
            
            print("--------------------------------Signup Response:----------------------------------")
            print(response)
            print("----------------------------------------------------------------------------------")
            
            if response.success == true {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    //--------------------------------------------------------------------------------------------------
    //MARK: - Universal Logout
    
    class func logout(banned:Bool = false, _ completion: @escaping (_ success: Bool) -> Void) {
        
        SocketIOManager.sharedInstance.stopSocketConnection()

        GCD.mainThread {
            
            if banned {
                //Google Logout
                GIDSignIn.sharedInstance().signOut()
                GIDSignIn.sharedInstance().disconnect()
                
                //Facebook Logout
                let loginManager = LoginManager()
                loginManager.logOut()
                
                DeviceManager.unregisterPushNotifications()

                GCD.mainThread(block: {
                    DataManager.clearAll()
                    DataManager.startupInit({
                        completion(true)
                    })
                })
            }

            guard let token  = DataManager.model.currentUser?.token else {magic("something wrong with token");return}
            
            //LOGOUT  DELETE /users/login
            API.delete(URL_LOGIN as AnyObject, userToken: token, completed: { (response) in
                
                print("--------------------------------Logout Response:----------------------------------")
                print(response)
                print("----------------------------------------------------------------------------------")
                
                //Universal Logout
                GCD.mainThread {
                    if DataManager.model.currentUser?.loginType == LoginType.google.rawValue {
                        //Google Logout
                        GIDSignIn.sharedInstance().signOut()
                        GIDSignIn.sharedInstance().disconnect()
                    } else if DataManager.model.currentUser?.loginType == LoginType.facebook.rawValue {
                        //Facebook Logout
                        let loginManager = LoginManager()
                        loginManager.logOut()
                    }
                }
                
                //DELETE /devices/:guid
                DeviceManager.unregisterDeviceBackend(token: token)
                DeviceManager.unregisterPushNotifications()
                
                GCD.mainThread(block: {
                    DataManager.clearAll()
                    DataManager.startupInit({
                        completion(true)
                    })
                })
                
                
                
                
            })
        }
    }
    
    //--------------------------------------------------------------------------------------------------
    //MARK: - Universal Login
    
    class func loginUniversal(_ loginType:LoginType, email:String, firstName:String, lastName:String, imageURL:String?, completion: @escaping (_ success: Bool, _ banned: Bool) -> Void) {
        
        var url = ""
        if let u = imageURL {url = u}
        
        let paramsDictionary = ["email":email, "firstName": firstName, "lastName": lastName, "avatarUrl" : url]
        
        //SIGNUP   POST /users
        API.post(URL_LOGIN_UNIVERSAL as AnyObject, payload: paramsDictionary as [String : AnyObject]?, userToken: nil, completed: { (response) in
            
            print("--------------------------------Universal Login Response:----------------------------------")
            print(response)
            print("----------------------------------------------------------------------------------")
            
            if response.success == true && response.code == 200 {
                if let token = response.token, let id = response.id {
                    print("token: \(token)")
                    print("id: \(id)")
                    print("email: \(email)")
                    print("url: \(url)")
                    
                    GCD.mainThread(block: {
                        self.write {
                            let user = DataManager.getRealm().create(User.self, value: ["id": id], update: true)
                            user.token = token
                            user.email = email
                            user.firstName = firstName
                            user.lastName = lastName
                            user.avatarUrl = imageURL
                            user.loginType = loginType.rawValue
                            DataManager.model.currentUser = user
                        }
                        DeviceManager.registerPushNotifications()
                        completion(true, false)
                    })
                    
                }
            } else if response.success == true && response.code == 204 {
                //User is Baned
                completion(true, true)
            } else {
                completion(false, false)
            }
        })
    }
    

}
