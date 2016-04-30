//
//  AppDelegate.swift
//  NotifyHub
//
//  Created by hiro on 2016/04/30.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa

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
    }


}

