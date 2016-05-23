//
//  UserModel.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/23.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserModel {
    func fetchUserId() {
        let gitHubModel = GitHubModel()
        let accessToken = gitHubModel.getAccessToekn()
        let params = ["access_token": accessToken]
        
        Alamofire.request(.GET, "https://api.github.com/user", headers:["Cache-Control": "no-cache"], parameters: params)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let json = JSON(object)
                self.setUserId(json["login"].string!)
        }
    }
    
    
    func setUserId(id: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(id, forKey: "github_id")
    }
    
    func getUserId() -> String {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults(["github_id": ""])
        let github_id = ud.objectForKey("github_id") as! String
        if "" == github_id {
            self.fetchUserId()
        }
        return github_id
    }
}