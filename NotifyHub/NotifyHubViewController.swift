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
import SwiftyJSON

class NotifyHubViewController: NSViewController, NSSearchFieldDelegate {
    
    @IBOutlet weak var preferenceBtn: NSButton!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    var lists: [[String:String]] = []
    var listsOrg: [[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let nib = NSNib(nibNamed: "MyCellView", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib!, forIdentifier: "MyCellView")
        
        let notificationModel = NotificationModel()
        notificationModel.fetchLists({ json in
            self.lists = json
            self.listsOrg = json
            self.tableView.reloadData()
        })
        
        if #available(OSX 10.11, *) {
            self.searchField.delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        self.preferenceBtn.action = #selector(openPreference)
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        if self.searchField.stringValue.characters.count > 0 {
            let filterPredicate = NSPredicate(format: "title CONTAINS[cd] %@", self.searchField.stringValue)
            let newLists = (self.lists as NSArray).filteredArrayUsingPredicate(filterPredicate)
            self.lists = newLists as! Array<[String:String]>
        } else {
            self.lists = self.listsOrg
        }
        self.tableView.reloadData()
    }
    
    func openPreference (){
        let preferenceViewController = PreferenceViewController()
        self.presentViewControllerAsModalWindow(preferenceViewController)
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
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        print(self.tableView.selectedRow)
        let gitHubModel = GitHubModel()
        let accessToken = gitHubModel.getAccessToekn()
        let headers = [
            "Authorization": "token " + accessToken
        ]
        
        Alamofire.request(.GET, self.lists[self.tableView.selectedRow]["url"]!, headers: headers)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: json["html_url"].string!)!)
        }
        
        
        
    }
}
