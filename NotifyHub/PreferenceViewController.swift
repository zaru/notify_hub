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
    
    @IBOutlet weak var checkboxOwn: NSButton!
    @IBOutlet weak var checkboxParticipating: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preference"
        checkboxOwn.state = (self.preferenceModel.getOwnerOnly()) ? NSOnState : NSOffState
        checkboxParticipating.state = (self.preferenceModel.getParticipating()) ? NSOnState : NSOffState
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
