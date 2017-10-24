//
//  String+Extensions.swift
//  Textor
//
//  Created by eugene golovanov on 8/12/16.
//  Copyright © 2016 eugene golovanov. All rights reserved.
//

import UIKit

public extension String {
    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func isURL() -> Bool {
        //swiftlint:disable:next custom_rules
        return self.lowercased().hasPrefix("http://") || self.lowercased().hasPrefix("https://")
    }
    
    
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    
}
