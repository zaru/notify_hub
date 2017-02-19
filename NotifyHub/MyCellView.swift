//
//  MyCellView.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/08.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa

class MyCellView: NSView {
    
    @IBOutlet weak var itemTitle: NSTextField!
    @IBOutlet weak var itemRepositoryName: NSTextField!
    @IBOutlet weak var itemUpdatedAt: NSTextField!
    @IBOutlet weak var itemIcon: NSImageView!
    @IBOutlet weak var itemType: NSTextField!
}
