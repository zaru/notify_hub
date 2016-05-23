//
//  PreferenceViewController.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/17.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {
    
    
    let preferenceModel = PreferenceModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func participating(sender: NSButton) {
        let state = (NSOnState == sender.state) ? true : false
        self.preferenceModel.setParticipating(state)
        
        
    }
    @IBAction func own(sender: NSButton) {
        let state = (NSOnState == sender.state) ? true : false
        self.preferenceModel.setOwnerOnly(state)
    }
    
}
