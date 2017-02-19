//
//  ColorUtil.swift
//  NotifyHub
//
//  Created by hiro on 2017/02/19.
//  Copyright © 2017年 zaru. All rights reserved.
//

import Cocoa
import Foundation

class ColorUtil {
    func NSColorFromRGB(rgbValue: UInt) -> NSColor {
        return NSColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
