//
//  NotifyHubViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/03.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
import Keys
import Alamofire
import AlamofireImage
import SwiftyJSON

class NotifyHubViewController: NSViewController, NSSearchFieldDelegate {
    
    @IBOutlet weak var logoutBtn: NSButton!
    @IBOutlet weak var preferenceBtn: NSButton!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    var lists: [[String:String]] = []
    var listsOrg: [[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        var timer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: #selector(NotifyHubViewController.timerFetch(_:)), userInfo: nil, repeats: true)
        
        // Do view setup here.
        let nib = NSNib(nibNamed: "MyCellView", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib!, forIdentifier: "MyCellView")
        tableView.hidden = true
        tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
        
        fetchNotificationData()
        
        if #available(OSX 10.11, *) {
            self.searchField.delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        self.searchField.focusRingType = NSFocusRingType.None
        
        self.preferenceBtn.action = #selector(openPreference)
        self.logoutBtn.action = #selector(logOut)
        
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
    
    func logOut (){
        let body: NSMutableDictionary = NSMutableDictionary()
        body.removeObjectForKey("code")
        
        let gitHubModel = GitHubModel()
        gitHubModel.removeAccessAotken()

    }
    
    func openPreference (){
        let preferenceViewController = PreferenceViewController(nibName: "PreferenceViewController", bundle: nil)
        self.presentViewControllerAsModalWindow(preferenceViewController!)
    }
    
    func timerFetch(timer: NSTimer){
        fetchNotificationData()
    }
    
    func fetchNotificationData(){
        let notificationModel = NotificationModel()
        notificationModel.fetchLists({ json in
            if (self.lists != json) {
                
                if (self.lists.count > 0) {
                    let dateOld = DateUtil.parseStringDate(self.lists[0]["updated_at"]!)
                    let dateNew = DateUtil.parseStringDate(json[0]["updated_at"]!)
                    if (dateOld.compare(dateNew) == NSComparisonResult.OrderedAscending) {
                        self.dispNotification(json[0])
                    }
                }
                
                self.lists = json
                self.listsOrg = json
                self.tableView.reloadData()
                self.tableView.hidden = false
                
            } else {
            }
        })
    }
    
    func dispNotification(data: [String:String]){
        let notification = NSUserNotification()
        notification.title = data["title"]
        notification.subtitle = data["repository"]
        notification.informativeText = data["updated_at"]
        Alamofire.request(.GET, data["icon"]!)
            .responseImage { response in
                if let image = response.result.value {
                    notification.contentImage = image
                    notification.userInfo = ["url" : data["url"]!]
                    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
                }
        }
    }
    
}

extension NotifyHubViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.lists.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("MyCellView", owner: self) as! MyCellView
        cell.itemTitle.stringValue = self.lists[row]["title"]!
        cell.itemRepositoryName.stringValue = self.lists[row]["repository"]!
        cell.itemUpdatedAt.stringValue = DateUtil.formatDate(self.lists[row]["updated_at"]!)
        
        let color = ColorUtil()
        if ("mention" == self.lists[row]["reason"]) {
            cell.itemType.stringValue = "mention"
            cell.itemType.backgroundColor = color.NSColorFromRGB(0x80e021)
        } else if ("PullRequest" == self.lists[row]["type"]) {
            cell.itemType.stringValue = "PR"
            cell.itemType.backgroundColor = color.NSColorFromRGB(0xff32a6)
        } else if ("Issue" == self.lists[row]["type"]) {
            cell.itemType.stringValue = "Issue"
            cell.itemType.backgroundColor = color.NSColorFromRGB(0x328eff)
        }
        cell.itemType.wantsLayer = true
        cell.itemType.layer?.cornerRadius = 4.0
        
        let notificationModel = NotificationModel()
        notificationModel.fetchDetail(self.lists[row]["url"]!, callback: { json in
            if ("mention" == self.lists[row]["reason"] && "" != json["body"]) {
                cell.itemTitle.stringValue = json["body"]!
            }
            self.lists[row]["html_url"] = json["html_url"]
            
            Alamofire.request(.GET, json["avatar"]!)
                .responseImage { response in
                    if let image = response.result.value {
                        cell.itemIcon.image = image
                        cell.itemIcon.layer!.cornerRadius = 12.0
                    }
            }
        })
        
        return cell
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: self.lists[self.tableView.selectedRow]["html_url"]!)!)
    }
}
