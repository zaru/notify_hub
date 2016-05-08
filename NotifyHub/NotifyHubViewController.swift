//
//  NotifyHubViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/03.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
import Alamofire
import AlamofireImage

class NotifyHubViewController: NSViewController {

    
    @IBOutlet weak var tableView: NSTableView!
    var lists: [[String:String]] = []
    
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
        cell.itemTitle.stringValue = self.lists[row]["title"]!
        cell.itemRepositoryName.stringValue = self.lists[row]["repository"]!
        cell.itemUpdatedAt.stringValue = self.lists[row]["updated_at"]!
        
        Alamofire.request(.GET, self.lists[row]["icon"]!)
            .responseImage { response in
                if let image = response.result.value {
                    cell.itemIcon.image = image
                }
        }
        return cell
    }
}
