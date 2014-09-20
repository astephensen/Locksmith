//
//  LocksmithServer.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

protocol LocksmithServerDelegate {
    func locksmithServerIsNowTrusted()
    func locksmithServerShortcutsModified()
}

class LocksmithServer: NSObject {
    var delegate: LocksmithServerDelegate?

    func isProcessTrusted() -> NSNumber {
        let isTrusted = AXIsProcessTrusted() == 1
        if isTrusted {
            delegate?.locksmithServerIsNowTrusted()
        }
        return NSNumber(bool: isTrusted)
    }
    
    func askForTrust() {
        let trusted = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options = [trusted: true]
        AXIsProcessTrustedWithOptions(options);
    }
    
    func reloadShortcuts() {
        delegate?.locksmithServerShortcutsModified()
    }
}
