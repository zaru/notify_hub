//
//  NotifyHubViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/03.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa

class NotifyHubViewController: NSViewController {

    
    @IBOutlet weak var tableView: NSTableView!
    var lists: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let nib = NSNib(nibNamed: "MyCellView", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib!, forIdentifier: "MyCellView")
        
        let notificationModel = NotificationModel()
        notificationModel.fetchLists({ json in
            self.lists = json
            self.tableView.reloadData()
        })
    }
    
}

extension NotifyHubViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.lists.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("MyCellView", owner: self) as! MyCellView
        cell.itemName.stringValue = "test"
        
        return cell
    }
}
