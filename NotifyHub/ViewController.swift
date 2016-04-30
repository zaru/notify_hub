//
//  ViewController.swift
//  test2
//
//  Created by hiro on 2016/05/01.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    @IBOutlet weak var wv: WebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string : "https://github.com/login/oauth/authorize?client_id=73a9147e0024a6958e7b&scope=notifications")
        let urlRequest = NSURLRequest(URL: url!)
        self.wv.mainFrame.loadRequest(urlRequest)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    


}

