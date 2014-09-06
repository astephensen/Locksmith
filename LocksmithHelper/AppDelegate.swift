//
//  AppDelegate.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, LocksmithServerDelegate {
    @IBOutlet weak var window: NSWindow!
    var keyMonitor: KeyMonitor!
    var locksmith: Locksmith!
    var locksmithServer: LocksmithServer!
    var locksmithServerConnection: NSConnection!

    func applicationDidFinishLaunching(aNotification: NSNotification?) {

        // Create the locksmith server so the preferences pane can connect to our helper application.
        locksmithServer = LocksmithServer()
        locksmithServer.delegate = self
        locksmithServerConnection = NSConnection.serviceConnectionWithName("LocksmithHelper", rootObject: locksmithServer);
        
        // Check if the application is already trusted and launch the locksmith instance.
        // If it isn't trusted we will wait for the locksmith server delegate to tell us when it is ok to start.
        if AXIsProcessTrusted() == 1 {
            setupLocksmith()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    // MARK: Functions
    
    func setupLocksmith() {
        if locksmith == nil {
            locksmith = Locksmith()
        }
    }
    
    // MARK: Locksmith Server Delegate
    
    func locksmithServerIsNowTrusted() {
        setupLocksmith()
    }
    
    func locksmithServerShortcutsModified() {
        locksmith.loadShortcutList()
    }
}

