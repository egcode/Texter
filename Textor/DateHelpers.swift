//
//  DateHelpers.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/8/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import Foundation

class DateHelpers {
    
    /**
     Timestamp
     */
    class func timestampFromDate(date:Date) -> Int {
        return Int(date.timeIntervalSince1970 * 1000)
    }
    
    class func dateFromTimestamp(timestamp:Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
    }
    
    /**
     Date String
     */
    class func dateStringFromDate(date:Date) -> String {
        if NSCalendar.current.isDateInToday(date) {
            return "Today"
        } else if NSCalendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: date)
    }
    /**
     Time String
     */
    class func timeStringFromDate(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }

    

}
