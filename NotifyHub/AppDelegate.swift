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
        fetchAccessToken(querys[1])
    }
    
    func fetchAccessToken(code: String) {
        let keys = NotifyhubKeys()
        
        let url: NSURL = NSURL(string: "https://github.com/login/oauth/access_token")!
        let body: NSMutableDictionary = NSMutableDictionary()
        body.setValue(keys.gitHubClientId(), forKey: "client_id")
        body.setValue(keys.gitHubClientSecret(), forKey: "client_secret")
        body.setValue(code, forKey: "code")
        
        post(url, body: body, completionHandler: { data, response, error in
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(responseString)
        })
    }
    
    let session: NSURLSession = NSURLSession.sharedSession()
    
    func post(url: NSURL, body: NSMutableDictionary, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))
        } catch {
            // Error Handling
            print("NSJSONSerialization Error")
            return
        }
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
    

}

