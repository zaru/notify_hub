//
//  PreferenceModel.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/18.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Foundation

class PreferenceModel {
    func getParticipating() -> Bool{
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults(["participating": false])
        return ud.objectForKey("participating") as! Bool
    }
    
    func setParticipating(participating: Bool) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(participating, forKey: "participating")
    }
}