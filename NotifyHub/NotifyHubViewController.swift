//
//  NotifyHubViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/03.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
//import Keys
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
        let preferenceViewController = PreferenceViewController()
        self.presentViewControllerAsModalWindow(preferenceViewController)
    }
    
    func timerFetch(timer: NSTimer){
        fetchNotificationData()
    }
    
    func fetchNotificationData(){
        let notificationModel = NotificationModel()
        notificationModel.fetchLists({ json in
            if (self.lists != json) {
                if (self.lists.count > 0) {
                    
                    let dateOld = self.parseStringDate(self.lists[0]["updated_at"]!)
                    let dateNew = self.parseStringDate(json[0]["updated_at"]!)
                    if (dateOld.compare(dateNew) == NSComparisonResult.OrderedAscending) {
                        self.dispNotification()
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
    
    func dispNotification(){
        let notification = NSUserNotification()
        notification.title = self.lists[0]["title"]
        notification.subtitle = self.lists[0]["repository"]
        notification.informativeText = self.lists[0]["updated_at"]
        Alamofire.request(.GET, self.lists[0]["icon"]!)
            .responseImage { response in
                if let image = response.result.value {
                    notification.contentImage = image
                    notification.userInfo = ["url" : self.lists[0]["url"]!]
                    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
                }
        }
    }
    
    //TODO: move to UtilsClass
    func parseStringDate(str: String) -> NSDate {
        let formatter = NSDateFormatter()
        let localeStyle = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.locale = localeStyle
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.dateFromString(str)!
    }
}

extension NotifyHubViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.lists.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("MyCellView", owner: self) as! MyCellView
        cell.itemTitle.stringValue = self.lists[row]["title"]!
        cell.itemRepositoryName.stringValue = self.lists[row]["repository"]!
        cell.itemUpdatedAt.stringValue = self.lists[row]["updated_at"]!
        
        let notificationModel = NotificationModel()
        notificationModel.fetchDetail(self.lists[row]["url"]!, callback: { json in
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
