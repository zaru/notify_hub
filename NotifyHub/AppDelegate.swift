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
import SwiftyJSON
import LoginServiceKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var window: NSWindow!
    var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    let MyNotification = "MyNotification"
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
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
        let querys = url!.query!.componentsSeparatedByString("=")
        print(querys[1])
        self.fetchAccessToken(querys[1])
        
        popover.performClose(nil)
    }
    
    func fetchAccessToken(code: String) {
        let keys = NotifyhubKeys()
        print("fetchAccessToken")
        print(code)
        
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
                
                NSNotificationCenter.defaultCenter().postNotificationName(self.MyNotification, object: nil)
            } catch  {
            }
        })
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
    
    
}

