//
//  AppDelegate.swift
//  NotifyHub
//
//  Created by hiro on 2016/04/30.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics
import Keys
import Alamofire
import SwiftyJSON
import LoginServiceKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var window: NSWindow!
    var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    let MyNotification = "MyNotification"

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        Fabric.with([Crashlytics.self])
        addingToLoginItems()
        
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults(["NSApplicationCrashOnExceptions": true])
        
        let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.updatePopoverView(_:)), name: MyNotification, object: nil)
        
        // debug setting
        NSURLCache.sharedURLCache().memoryCapacity = 0
        NSURLCache.sharedURLCache().diskCapacity = 0
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusImage")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.behavior = .Transient
        
        let gitHubModel = GitHubModel()
        let accessToken = gitHubModel.getAccessToekn()
        if accessToken == "" {
            popover.contentViewController = GitHubOauthViewController(nibName: "GitHubOauthViewController", bundle: nil)
        } else {
            popover.contentViewController = NotifyHubViewController(nibName: "NotifyHubViewController", bundle: nil)
        }
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        let appleEventManager:NSAppleEventManager = NSAppleEventManager.sharedAppleEventManager()
        appleEventManager.setEventHandler(self, andSelector: #selector(AppDelegate.handleGetURLEvent(_:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        let appUrl = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("", isDirectory: true)
        let a:Bool = true
        _ = LSRegisterURL(appUrl as CFURL!, a)
        
        
        fetchFeed()
        fetchNotificationData()
        
    }
    
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
            NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        
    }
    
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        let info = notification.userInfo as! [String:String]
        let gitHubModel = GitHubModel()
        let accessToken = gitHubModel.getAccessToekn()
        let headers = [
            "Authorization": "token " + accessToken
        ]
        
        Alamofire.request(.GET, info["url"]!, headers: headers)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: json["html_url"].string!)!)
        }
    }
    
    func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        let url = NSURL(string: event!.paramDescriptorForKeyword(AEKeyword(keyDirectObject))!.stringValue!)
        let querys = url!.query!.componentsSeparatedByString("&")
        let code = querys[0].componentsSeparatedByString("=")
        self.fetchAccessToken(code[1])
        
        popover.performClose(nil)
    }
    
    func fetchAccessToken(code: String) {
        let keys = NotifyhubKeys()
        
        let parameters = [
            "client_id": keys.gitHubClientId(),
            "client_secret": keys.gitHubClientSecret(),
            "code": code
        ]
        
        Alamofire.request(.POST, "https://github.com/login/oauth/access_token", headers:["Accept": "application/json"], parameters: parameters, encoding: .URLEncodedInURL)
            .validate()
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                let accessToken = json["access_token"].stringValue
                GitHubModel().setAccessToken(accessToken)
                NSNotificationCenter.defaultCenter().postNotificationName(self.MyNotification, object: nil)
        }
    }
    
    func updatePopoverView(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.popover.contentViewController = NotifyHubViewController(nibName: "NotifyHubViewController", bundle: nil)
        })
    }
    
    func addingToLoginItems() {
        let appPath = NSBundle.mainBundle().bundlePath
        LoginServiceKit.addPathToLoginItems(appPath)
    }
    
    
    
    
    
    
    
    
    
    
    
    // 試しにNotifyHubViewControllerからデータ取得部分を分離する
    // 今後は、裏で独自にデータ取得して、Viewはそれを参照するだけにする
    
    var lists: [[String:String]] = []
    var listsOrg: [[String:String]] = []
    
    func fetchFeed() {
        _ = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: #selector(AppDelegate.timerFetch(_:)), userInfo: nil, repeats: true)
        
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
                // ここでデータを保持しておいてViewから参照できるようにする
//                self.tableView.reloadData()
//                self.tableView.hidden = false
                
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

