//
//  AppDelegate.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//

import Cocoa
import Foundation
import NotificationCenter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    var mainWindow: NSWindow!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        mainWindow = NSApplication.sharedApplication().windows[0]
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if(!flag){
            mainWindow!.makeKeyAndOrderFront(self)
        }
        return true
    }

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
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

