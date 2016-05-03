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
    var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        let menu = NSMenu()
        self.statusItem.title = "NotifyHub"
        self.statusItem.highlightMode = true
        self.statusItem.menu = menu
        
        let menuItem = NSMenuItem()
        menuItem.title = "Quit"
        menuItem.action = Selector("quit:")
        menu.addItem(menuItem)
        
        
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
        
        let accessToken = getAccessToekn()
        if(accessToken != ""){
            Alamofire.request(.GET, "https://api.github.com/notifications", parameters: ["access_token": accessToken])
                .responseJSON { response in
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
            }
        }
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
                self.setAccessToken(accessToken as! String)
            } catch  {
            }
        })
    }
    
    func getAccessToekn() -> String{
        let ud = NSUserDefaults.standardUserDefaults()
        let accessToken = ud.objectForKey("access_token") as? String
        return accessToken!
    }
    
    func setAccessToken(accessToken: String) {
        print(accessToken)
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(accessToken, forKey: "access_token")
    }
    
    
}

