//
//  NotifyHubViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/03.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa

class NotifyHubViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    
    @IBOutlet weak var tableView: NSTableView!
    var lists: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.headerView = nil
        
        let notificationModel = NotificationModel()
        notificationModel.fetchLists({ json in
            self.lists = json
            self.tableView.reloadData()
        })
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        return self.lists.count
    }
    func tableView(aTableView: NSTableView,
                   objectValueForTableColumn aTableColumn: NSTableColumn?,
                                             row rowIndex: Int) -> AnyObject?
    {
        let columnName = aTableColumn?.identifier
        
        if columnName == "Message" {
            return self.lists[rowIndex]
        }
        return ""              
    }
    
}
