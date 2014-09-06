//
//  AppDelegate.swift
//  Locksmith
//
//  Created by Alan Stephensen on 6/09/2014.
//  Copyright (c) 2014 Alan Stephensen. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    var setupWindowController: NSWindowController!
    var testingWindowController: NSWindowController!
    var keyMonitor: KeyMonitor!
    var locksmith: Locksmith!

    func applicationDidFinishLaunching(aNotification: NSNotification?) {

        if SetupWindowController.shouldDisplay() {
            setupWindowController = SetupWindowController(windowNibName: "SetupWindowController")
            setupWindowController.loadWindow()
            setupWindowController.showWindow(self)
        } else {
            setupLocksmith()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    // MARK: Functions
    
    func setupLocksmith() {
        locksmith = Locksmith()
    }
}

