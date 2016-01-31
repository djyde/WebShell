//
//  WebShellDebug.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit

// @wdg Add Debug support
// Issue: None.
// This extension will handle the Debugging options.
extension ViewController {
    
    // @wdg Override settings via commandline
    // .... Used for popups, and debug options.
    func checkSettings() -> Void {
        // Need to overwrite settings?
        if (Process.argc > 0) {
            for (var i = 1; i < Int(Process.argc) ; i = i + 2) {
                if ((String(Process.arguments[i])) == "-NSDocumentRevisionsDebugMode") {
                    if ((String(Process.arguments[i + 1])) == "YES") {
                        SETTINGS["debugmode"] = true
                        SETTINGS["consoleSupport"] = true
                    }
                }
                
                if ((String(Process.arguments[i])).uppercaseString == "-DEBUG") {
                    if ((String(Process.arguments[i + 1])).uppercaseString == "YES" || (String(Process.arguments[i + 1])).uppercaseString == "true") {
                        SETTINGS["debugmode"] = true
                        SETTINGS["consoleSupport"] = true
                    }
                }
                
                if ((String(Process.arguments[i])) == "-dump-args") {
                    self._debugDumpArguments("")
                }
                
                if ((String(Process.arguments[i])) == "-url") {
                    SETTINGS["url"] = String(Process.arguments[i + 1])
                }
                
                if ((String(Process.arguments[i])) == "-height") {
                    SETTINGS["initialWindowHeight"] = (Int(Process.arguments[i + 1]) > 30) ? Int(Process.arguments[i + 1]) : Int(30)
                }
                
                if ((String(Process.arguments[i])) == "-width") {
                    SETTINGS["initialWindowWidth"] = (Int(Process.arguments[i + 1]) > 30) ? Int(Process.arguments[i + 1]) : Int(30)
                }
            }
        }
        
        initWindow()
    }
    
    // Edit contextmenu...
    func webView(sender: WebView!, contextMenuItemsForElement element: [NSObject : AnyObject]!, var defaultMenuItems: [AnyObject]!) -> [AnyObject]! {
        // Add debug menu. (if enabled)
        if (SETTINGS["debugmode"] as! Bool) {
            let debugMenu = NSMenu(title: "Debug")
            debugMenu.addItem(NSMenuItem.init(title: "Open New window", action: Selector("_debugNewWindow:"), keyEquivalent: ""))
            debugMenu.addItem(NSMenuItem.init(title: "Print arguments", action: Selector("_debugDumpArguments:"), keyEquivalent: ""))
            debugMenu.addItem(NSMenuItem.init(title: "Open URL", action: Selector("_openURL:"), keyEquivalent: ""))
            debugMenu.addItem(NSMenuItem.init(title: "Report an issue on this page", action: Selector("_reportThisPage:"), keyEquivalent: ""))
            debugMenu.addItem(NSMenuItem.init(title: "Print this page", action: Selector("printThisPage:"), keyEquivalent: ""))
            debugMenu.addItem(NSMenuItem.separatorItem())
            debugMenu.addItem(NSMenuItem.init(title: "Fire some random Notifications", action: Selector("__sendNotifications:"), keyEquivalent: ""))
            debugMenu.addItem(NSMenuItem.init(title: "Reset localstorage", action: Selector("resetLocalStorage:"), keyEquivalent: ""))
            
            let item = NSMenuItem.init(title: "Debug", action: Selector("_doNothing:"), keyEquivalent: "")
            item.submenu = debugMenu
            
            defaultMenuItems.append(item)
        }
        
        defaultMenuItems.append(NSMenuItem.separatorItem())
        defaultMenuItems.append(NSMenuItem.init(title: "Quit", action: Selector("Quit:"), keyEquivalent: ""))
        
        return defaultMenuItems
    }
    
    // Debug: doNothing
    func _doNothing(Sender: AnyObject) -> Void {
        // _doNothing
    }
    
    // Debug: Open new window
    func _debugNewWindow(Sender: AnyObject) -> Void {
        openNewWindow("https://www.google.nl/search?client=safari&rls=en&q=new+window&ie=UTF-8&oe=UTF-8&gws_rd=cr&ei=_8eKVs2WFIbFPd7Sr_gN", height: "0", width: "0")
    }
    
    // Debug: Print arguments
    func _debugDumpArguments(Sender: AnyObject) -> Void {
        print(Process.arguments)
    }
    
    // Debug: Send notifications (10)
    func __sendNotifications(Sender: AnyObject) -> Void {
        // Minimize app
        NSApplication.sharedApplication().keyWindow?.miniaturize(self)
        
        // Fire 10 Notifications
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(05), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(15), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(25), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(35), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(45), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(55), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(65), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(75), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(85), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(95), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
    }
    
    // Debug: Send notifications (10): Real sending.
    func ___sendNotifications() -> Void {
        // Minimize app
        if (NSApplication.sharedApplication().keyWindow?.miniaturized == false) {
            NSApplication.sharedApplication().keyWindow?.miniaturize(self)
        }
        
        // Send Actual notification.
        makeNotification("Test Notification", message: "Hi!", icon: "https://camo.githubusercontent.com/ee999b2d8fa5413229fdc69e0b53144f02b7b840/687474703a2f2f376d6e6f79372e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7765627368656c6c2f6c6f676f2e706e673f696d616765566965772f322f772f313238")
    }
    
    func _openURL(Sender: AnyObject) -> Void {
        let msg = NSAlert()
        msg.addButtonWithTitle("OK") // 1st button
        msg.addButtonWithTitle("Cancel") // 2nd button
        msg.messageText = "URL"
        msg.informativeText = "Where you need to go?"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = "http://"
        
        msg.accessoryView = txt
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            self.loadUrl(txt.stringValue)
        }
    }
    
    func _reportThisPage(Sender: AnyObject) -> Void {
        let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.URL?.absoluteString)!
        let host: String = (mainWebview.mainFrame.dataSource?.request.URL?.host)!
        
        let issue: String = String("Problem loading \(host)").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!.stringByReplacingOccurrencesOfString("&", withString: "%26")
        var body: String = (String("There is a problem loading \(currentUrl)").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())?.stringByReplacingOccurrencesOfString("&", withString: "%26"))!
        body.appendContentsOf("%0D%0AThe%20problem%20is%3A%0D%0A...")
        
        let url: String = "https://github.com/djyde/WebShell/issues/new?title=\(issue)&body=\(body)"
        
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: (url as String))!)
    }

}
