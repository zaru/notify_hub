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
        let accessToken = ud.objectForKey("access_token") as? String
        return accessToken!
    }
    
    func setAccessToken(accessToken: String) {
        print(accessToken)
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(accessToken, forKey: "access_token")
    }
}