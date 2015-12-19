//
//  AppDelegate.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindow: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        mainWindow = NSApplication.sharedApplication().windows[0] 
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if(!flag){
            mainWindow!.makeKeyAndOrderFront(self)
        }
        return true
    }
}

