//
//  GitHubOauthViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/06.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
import WebKit
import Keys

class GitHubOauthViewController: NSViewController {

    @IBOutlet weak var wv: WebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie : NSHTTPCookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "https://github.com")!)! as [NSHTTPCookie] {
            storage.deleteCookie(cookie)
        }
        
        let keys = NotifyhubKeys()
        
        let url = NSURL(string : "https://github.com/login/oauth/authorize?client_id=" + keys.gitHubClientId() + "&scope=notifications")
        let urlRequest = NSURLRequest(URL: url!)
        self.wv.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12A365 Safari/600.1.4"
        self.wv.mainFrame.loadRequest(urlRequest)
    }
    
}
