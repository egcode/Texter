//
//  Constants.swift
//  Textor
//
//  Created by eugene golovanov on 8/10/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import Foundation
import UIKit


#if HOME
let URL_API = "http://192.168.0.24:3000"    // HOME

//#elseif KIWI
#else
    let URL_API = "https://your-server.com"   // SERVER
#endif

let URL_LOGIN = URL_API + "/users/login"
let URL_USERS = URL_API + "/users"
let URL_LOGIN_UNIVERSAL = URL_API + "/login/universal"

let DEVICE_UUID = UIDevice.current.identifierForVendor!.uuidString
let URL_DEVICES = URL_API + "/devices"
let URL_DEVICES_ID = URL_API + "/devices/" + DEVICE_UUID

//S3 AWS
let GET_TOKEN_URL = URL_API + "/presigned"

let KEY_CRYPTOJS = "yourKey!@#!"

//Status

let MESSAGE_STATUS_NOT_SENT = "not sent"
let MESSAGE_STATUS_SENT = "sent"
let MESSAGE_STATUS_DELIVERED = "delivered"
let MESSAGE_STATUS_SEEN = "seen"
let MESSAGE_STATUS_SENDING = "sending"
let MESSAGE_STATUS_GETTING = "getting"

//Banner Constants
let BOTTOM_BANNER_VIEW_TAG : Int            = 55
let BOTTOM_BANNER_CONNECTION_VIEW_TAG : Int = 56
let BANNER_HEIGHT:CGFloat                   = 25
let GLOBAL_FRAME                            = UIScreen.main.bounds
let CONNECTION_LABEL_NAV_TAG : Int          = 57
let CONNECTION_LABEL_TAG : Int              = 58
let CONNECTING_MSG_CONNECTING               = "Connecting"
let CONNECTING_MSG_WAITING_NET              = "No Network"

//Image
let DOWNLOAD_WAIT = 5   // Second To wait of download
let UPLOAD_WAIT = 5     // Second To wait of upload

let IMAGE_ORIG_MAX      :CGFloat = 1024  // Maximum side of upload and download image
let IMAGE_THUMBNAIL_MAX :CGFloat = UIScreen.main.bounds.width  // Maximum side of thumbnail, view dependent

//Typing
let TYPING_RECEIVE_WAIT = 3     // Second To show typing label
let TYPING_SEND_WAIT = 2     // Second To show typing label

//Device
struct DeviceType {
    static let IS_IPHONE_5_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH <= 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}
// Device size
struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}


