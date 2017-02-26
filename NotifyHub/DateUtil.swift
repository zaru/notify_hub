//
//  DateUtil.swift
//  NotifyHub
//
//  Created by hiro on 2017/02/26.
//  Copyright © 2017年 zaru. All rights reserved.
//

import Foundation

class DateUtil {
    static func parseStringDate(str: String) -> NSDate {
        let formatter = NSDateFormatter()
        let localeStyle = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.locale = localeStyle
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.dateFromString(str)!
    }
}
