//
//  AppDelegate.swift
//  NotifyHub
//
//  Created by hiro on 2016/04/30.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
import Keys
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var window: NSWindow!
    var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // debug setting
        NSURLCache.sharedURLCache().memoryCapacity = 0
        NSURLCache.sharedURLCache().diskCapacity = 0
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusImage")
            button.action = Selector("togglePopover:")
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
        let notification = NSUserNotification()
        notification.title = "タイトル"
        notification.subtitle = "サブタイトル1"
        notification.informativeText = "test"
        notification.contentImage =  NSImage(named: "icon_256")
        notification.userInfo = ["title" : "タイトル"]
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        let appleEventManager:NSAppleEventManager = NSAppleEventManager.sharedAppleEventManager()
        appleEventManager.setEventHandler(self, andSelector: "handleGetURLEvent:replyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        let appUrl = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("", isDirectory: true)
        let a:Bool = true
        _ = LSRegisterURL(appUrl as CFURL!, a)
        
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
        
        print(info["title"]!)
    }
    
    func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        let url = NSURL(string: event!.paramDescriptorForKeyword(AEKeyword(keyDirectObject))!.stringValue!)
        let querys = url!.query!.componentsSeparatedByString("=")
        print(querys[1])
        self.fetchAccessToken(querys[1])
        
        popover.performClose(nil)
        popover.contentViewController = NotifyHubViewController(nibName: "NotifyHubViewController", bundle: nil)
    }
    
    func fetchAccessToken(code: String) {
        let keys = NotifyhubKeys()
        
        let url: NSURL = NSURL(string: "https://github.com/login/oauth/access_token")!
        let body: NSMutableDictionary = NSMutableDictionary()
        body.setValue(keys.gitHubClientId(), forKey: "client_id")
        body.setValue(keys.gitHubClientSecret(), forKey: "client_secret")
        body.setValue(code, forKey: "code")
        
        let request: Request = Request()
        
        request.post(url, body: body, completionHandler: { data, response, error in
            do {
                let responseJson = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                let accessToken = responseJson["access_token"]!
                GitHubModel().setAccessToken(accessToken as! String)
            } catch  {
            }
        })
    }
    
    
}

