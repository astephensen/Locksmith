//
//  KeyMonitor.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

protocol KeyMonitorDelegate {
    func keyMonitorDidMonitorKeyPress(keyMonitor: KeyMonitor, key: String)
    func keyMonitorDidMonitorSpacePress(keyMonitor: KeyMonitor)
    func keyMonitorDidMonitorBackspacePress(keyMonitor: KeyMonitor)
}

class KeyMonitor: NSObject {
    var eventMonitor: AnyObject!
    var delegate: KeyMonitorDelegate?
    
    /**
    Starts monitoring all keyboard events. Notifying any registered delegates.
    */
    func startMonitoring() {
        eventMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(.KeyUpMask, handler: { (event: NSEvent!) -> Void in
            switch event.keyCode {
            // Spacebar.
            case 49:
                self.delegate?.keyMonitorDidMonitorSpacePress(self)
            // Backspace.
            case 51:
                self.delegate?.keyMonitorDidMonitorBackspacePress(self)
            default:
                let characters = event.characters
                self.delegate?.keyMonitorDidMonitorKeyPress(self, key: characters)
            }
        })
        println("Started monitoring.")
    }
    
    /**
    Stops monitoring all keyboard events.
    */
    func stopMonitoring() {
        NSEvent.removeMonitor(eventMonitor)
        eventMonitor = nil
        println("Stopped monitoring.")
    }
}
