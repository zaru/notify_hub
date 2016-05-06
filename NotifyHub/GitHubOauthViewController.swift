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
        
        let keys = NotifyhubKeys()
        
        let url = NSURL(string : "https://github.com/login/oauth/authorize?client_id=" + keys.gitHubClientId() + "&scope=notifications")
        let urlRequest = NSURLRequest(URL: url!)
        self.wv.mainFrame.loadRequest(urlRequest)
    }
    
}
