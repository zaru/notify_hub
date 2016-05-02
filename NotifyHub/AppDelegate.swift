//
//  AppDelegate.swift
//  NotifyHub
//
//  Created by hiro on 2016/04/30.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
import Keys

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
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
            let url: NSURL = NSURL(string: "https://api.github.com/notifications?access_token=" + accessToken)!
            let request: Request = Request()
            
            request.get(url, completionHandler: { data, response, error in
                do {
                    let responseJson = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
                    print(responseJson)
                } catch  {
                }
            })
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

