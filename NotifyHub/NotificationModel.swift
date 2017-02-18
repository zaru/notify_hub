//
//  NotificationModel.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/04.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NotificationModel {
    
    func fetchLists(callback: (Array<[String:String]>) -> Void) {
        let gitHubModel = GitHubModel()
        let accessToken = gitHubModel.getAccessToekn()
        if(accessToken != ""){
            
            var params = ["access_token": accessToken]
            if PreferenceModel().getParticipating() {
                params["participating"] = "true"
            }
            
            Alamofire.request(.GET, "https://api.github.com/notifications", headers:["Cache-Control": "no-cache"], parameters: params)
                .responseJSON { response in
                    guard let object = response.result.value else {
                        return
                    }
                    let json = JSON(object)
                    var result: [[String:String]] = []
                    if PreferenceModel().getOwnerOnly() {
                        let userId = UserModel().getUserId()
                        print(userId)
                        json.forEach { (_, json) in
                            if userId == json["repository"]["owner"]["login"].string! {
                                let dic:[String:String] = [
                                    "title":json["subject"]["title"].string!,
                                    "type":json["subject"]["type"].string!,
                                    "repository":json["repository"]["full_name"].string!,
                                    "url":json["subject"]["url"].string!,
                                    "updated_at":json["updated_at"].string!,
                                    "icon":json["repository"]["owner"]["avatar_url"].string!
                                ]
                                result.append(dic)
                            }
                        }
//                        json = json.filter({ "zaru" == $1["repository"]["owner"]["login"] })
                    } else {
                        json.forEach { (_, json) in
                            
                            let dic:[String:String] = [
                                "title":json["subject"]["title"].string!,
                                "type":json["subject"]["type"].string!,
                                "repository":json["repository"]["full_name"].string!,
                                "url":json["subject"]["url"].string!,
                                "updated_at":json["updated_at"].string!,
                                "icon":json["repository"]["owner"]["avatar_url"].string!
                            ]
                            result.append(dic)
                        }
                    }
                    callback(result)
            }
        }
    }
    
    func fetchDetail(url: String, callback: ([String:String]) -> Void) {
        let gitHubModel = GitHubModel()
        let accessToken = gitHubModel.getAccessToekn()
        if(accessToken != ""){
            let params = ["access_token": accessToken]
            Alamofire.request(.GET, url, parameters: params)
                .responseJSON { response in
                    guard let object = response.result.value else {
                        return
                    }
                    let json = JSON(object)
                    
                    
                    let dic:[String:String] = [
                        "avatar":json["user"]["avatar_url"].string!,
                        "body":json["body"].stringValue
                    ]
                    callback(dic)

            }
        }
    }

}
