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
    
    func getOwnerOnly() -> Bool{
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults(["owner_only": false])
        return ud.objectForKey("owner_only") as! Bool
    }
    
    func setOwnerOnly(participating: Bool) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(participating, forKey: "owner_only")
    }
}