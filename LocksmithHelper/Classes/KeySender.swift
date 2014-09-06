//
//  KeySender.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

class KeySender: NSObject {

    func sendString(stringToSend: String) {
        
        // Create the base keyboard events.
        let keyEventDown = CGEventCreateKeyboardEvent(nil, 7, true).takeRetainedValue()
        let keyEventUp = CGEventCreateKeyboardEvent(nil, 7, false).takeRetainedValue()
        
        // Loop through each character in the UTF16 representation of the string.
        for character in stringToSend.utf16 {
            
            // We can now cast it directly to a UniChar, update the events and post.
            var unichar = character as UniChar
            CGEventKeyboardSetUnicodeString(keyEventDown, 1, &unichar)
            CGEventKeyboardSetUnicodeString(keyEventUp, 1, &unichar);
            CGEventPost(CGEventTapLocation(kCGHIDEventTap), keyEventDown);
            CGEventPost(CGEventTapLocation(kCGHIDEventTap), keyEventUp);
        }
    }
    
    func sendBackspaces(backspaceCount: Int) {
     
        // Similar to sending a string, except we send the backspace key (51) a certain number of times.
        let keyEventDown = CGEventCreateKeyboardEvent(nil, 51, true).takeRetainedValue()
        let keyEventUp = CGEventCreateKeyboardEvent(nil, 51, false).takeRetainedValue()
        for backspaceIndex in 0..<backspaceCount {
            CGEventPost(CGEventTapLocation(kCGHIDEventTap), keyEventDown);
            CGEventPost(CGEventTapLocation(kCGHIDEventTap), keyEventUp);
        }
    }
}
