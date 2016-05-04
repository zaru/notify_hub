//
//  NotifyHubViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/03.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa

class NotifyHubViewController: NSViewController {

    @IBOutlet weak var tv: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let notificationModel = NotificationModel()
        notificationModel.fetchLists({ json in
            print(json)
        })
    }
    
}
