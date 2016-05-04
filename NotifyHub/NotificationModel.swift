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
    
    func fetchLists(callback: (Array<String>) -> Void) {
        let gitHubModel = GitHubModel()
        let accessToken = gitHubModel.getAccessToekn()
        if(accessToken != ""){
            Alamofire.request(.GET, "https://api.github.com/notifications", parameters: ["access_token": accessToken])
                .responseJSON { response in
                    guard let object = response.result.value else {
                        return
                    }
                    let json = JSON(object)
                    var result: [String] = []
                    json.forEach { (_, json) in
                        result.append(json["subject"]["title"].string!)
                    }
                    callback(result)
            }
        }
    }
    
}