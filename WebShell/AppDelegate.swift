//
//  AppDelegate.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//

import Cocoa
import Foundation

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
    
    @IBAction func goHome(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("goHome", object: nil)
    }
    @IBAction func reload(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
    }
    @IBAction func copyUrl(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("copyUrl", object: nil)
    }
}

