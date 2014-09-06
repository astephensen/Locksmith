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
        
        // TODO: Load a real list.
        shortcutList["test"] = "superawesometest"
        shortcutList["asdf"] = "23rerg34aerhaerh"
    }
    
    func checkBuffer() {
        
        // Check if the buffer matches a replacement.
        var clearBuffer = true
        for (shortcut, replacement) in shortcutList {
            println(shortcut)
            let range = shortcut.rangeOfString(buffer, options: .AnchoredSearch)
            if range != nil {
                if shortcut == buffer {
                    sendShortcut(shortcut)
                    break
                } else {
                    clearBuffer = false
                }
            }
        }
        
        if clearBuffer {
            buffer.removeAll()
        }
    }
    
    func sendShortcut(shortcut: String) {
        keySender.sendBackspaces(countElements(shortcut))
        keySender.sendString(shortcutList[shortcut]!)
    }
    
    // MARK: Key Monitor Delegate
    
    func keyMonitorDidMonitorKeyPress(keyMonitor: KeyMonitor, key: String) {
        buffer += key
        checkBuffer()
    }
}
