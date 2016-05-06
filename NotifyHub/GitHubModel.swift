//
//  GitHubModel.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/04.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Foundation

class GitHubModel {
    func getAccessToekn() -> String{
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults(["access_token": ""])
        return ud.objectForKey("access_token") as! String
    }
    
    func setAccessToken(accessToken: String) {
        print(accessToken)
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(accessToken, forKey: "access_token")
    }
}