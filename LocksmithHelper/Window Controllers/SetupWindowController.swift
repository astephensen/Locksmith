//
//  SetupWindowController.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

class SetupWindowController: NSWindowController {
    var trustedCheckTimer: NSTimer!
    
    /**
    Returns whether the setup window controller should display.
    
    :returns: A flag indicating whether the view controller should be shown.
    */
    class func shouldDisplay() -> Bool {
        
        if AXIsProcessTrusted() == 1 {
            println("Process is trusted. Setup window controller will not be displayed.")
            return false
        }
        
        println("Process is untrusted. Setup window controller will be displayed.")
        return true
    }

    // MARK: Lifecycle
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func setupButtonClicked(AnyObject) {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as NSDictionary
        if AXIsProcessTrustedWithOptions(options) == 0 {
            println("Showing prompt.")
            trustedCheckTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "checkTrusted", userInfo: nil, repeats: true)
        }
    }
    
    // MARK: Timer
    
    func checkTrusted() {
        if AXIsProcessTrusted() == 1 {
            println("Process is now trusted.")
            return
        }
        
        println("Process is still untrusted.")
    }
    
}
