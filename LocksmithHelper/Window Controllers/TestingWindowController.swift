//
//  TestingWindowController.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

class TestingWindowController: NSWindowController, KeyMonitorDelegate {
    var keySender: KeySender!
    var keyMonitor: KeyMonitor!
    
    override func awakeFromNib() {
        keySender = KeySender()
        keyMonitor = KeyMonitor()
        keyMonitor.delegate = self
        keyMonitor.startMonitoring()
    }
    
    override func windowDidLoad() {    
        super.windowDidLoad()
    }
    
    @IBAction func sendTestKeystrokes(AnyObject) {
        
        // Send the keystrokes after a short delay.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.keySender.sendString("Hello World")
        }
    }
    
    // MARK: KeyMonitorDelegate
    
    func keyMonitorDidMonitorKeyPress(keyMonitor: KeyMonitor, key: String) {
        println(key)
    }
}
