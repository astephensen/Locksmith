//
//  Locksmith.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

class Locksmith: NSObject, KeyMonitorDelegate {
    var keyMonitor: KeyMonitor
    var keySender: KeySender
    var shortcutList: [String: String]
    var buffer: String
    
    override init() {
        keyMonitor = KeyMonitor()
        keySender = KeySender()
        shortcutList = [String: String]()
        buffer = ""
        super.init()
        
        keyMonitor.delegate = self
        keyMonitor.startMonitoring()
        loadShortcutList()
    }
    
    // MARK: Functions
    
    func loadShortcutList() {
        
        // Load the array the preference pane has assembled and flatten it into a single dictionary.
        shortcutList = [String: String]()
        let shortcuts = NSUserDefaults.standardUserDefaults().arrayForKey("shortcuts")
        if shortcuts != nil {
            for shortcutObject in shortcuts! {
                let shortcut = shortcutObject["shortcut"] as String
                let replacement = shortcutObject["replacement"] as String
                shortcutList[shortcut] = replacement
            }
        }
        
        println("-- Loaded Shortcuts --")
        println(shortcutList)
    }

    func checkBuffer() {
        
        // println("Buffer is \(buffer)")

        // Check if the buffer matches a replacement.
        var clearBuffer = true
        for (shortcut, replacement) in shortcutList {
            // We check the suffix as the user may have select-all and deleted, which fills the buffer with garbage. This seems to work fairly well.
            if buffer.hasSuffix(shortcut) {
                sendShortcut(shortcut)
                break
            }
        }

        // Once the buffer has been checked it will be cleared for the next set of keys.
        buffer.removeAll()
    }
    
    func sendShortcut(shortcut: String) {
        keySender.sendBackspaces(countElements(shortcut) + 1)
        keySender.sendString(shortcutList[shortcut]!)
    }
    
    // MARK: Key Monitor Delegate
    
    func keyMonitorDidMonitorKeyPress(keyMonitor: KeyMonitor, key: String) {
        buffer += key
    }
    
    func keyMonitorDidMonitorBackspacePress(keyMonitor: KeyMonitor) {
        if countElements(buffer) > 0 {
            buffer.removeAtIndex(buffer.endIndex.predecessor())
        }
    }
    
    func keyMonitorDidMonitorSpacePress(keyMonitor: KeyMonitor) {
        checkBuffer()
    }
}
