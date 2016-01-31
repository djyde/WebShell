//
//  WebShellPageActions.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import AppKit

extension ViewController {
    // @wdg Add Print Support
    // Issue: #39
    func printThisPage() -> Void {
        let url = mainWebview.mainFrame.dataSource?.request?.URL?.absoluteString
        
        let operation: NSPrintOperation = NSPrintOperation.init(view: mainWebview)
        operation.jobTitle = "Printing \(url!)"
        
        // If want to print landscape
        operation.printInfo.orientation = NSPaperOrientation.Landscape
        operation.printInfo.scalingFactor = 0.7
        
        if operation.runOperation() {
            print("Printed?")
        }
    }
    
    func addObservers() {
        // add menu action observers
        let observers = ["goHome", "reload", "copyUrl", "clearNotificationCount", "printThisPage"]
        
        for observer in observers {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString(observer), name: observer, object: nil)
        }
    }
    
    func goHome() {
        loadUrl((SETTINGS["url"] as? String)!)
    }
    
    func reload() {
        let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.URL?.absoluteString)!
        loadUrl(currentUrl)
    }
    
    func copyUrl() {
        let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.URL?.absoluteString)!
        let clipboard: NSPasteboard = NSPasteboard.generalPasteboard()
        clipboard.clearContents()
        
        clipboard.setString(currentUrl, forType: NSStringPboardType)
    }
    
    func initSettings() {
        // controll the progress bar
        if (!(SETTINGS["showLoadingBar"] as? Bool)!) {
            progressBar.hidden = true // @wdg: Better progress indicator | Issue: #37
        }
        
        // set launching text
        launchingLabel.stringValue = (SETTINGS["launchingText"] as? String)!
    }
    
    func initWindow() {
        firstAppear = false
        
        // set window size
        var frame: NSRect = mainWindow.frame
        
        let WIDTH: CGFloat = CGFloat(SETTINGS["initialWindowWidth"] as! Int),
        HEIGHT: CGFloat = CGFloat(SETTINGS["initialWindowHeight"] as! Int)
        
        frame.size.width = WIDTH
        frame.size.height = HEIGHT
        
        // @wdg Fixed screen position (now it centers)
        // Issue: #19
        // Note: do not use HEIGHT, WIDTH for some strange reason the window will be positioned 25px from bottom!
        let ScreenHeight: CGFloat = (NSScreen.mainScreen()?.frame.size.width)!,
        WindowHeight: CGFloat = CGFloat(SETTINGS["initialWindowWidth"] as! Int), // do not use HEIGHT!
        ScreenWidth: CGFloat = (NSScreen.mainScreen()?.frame.size.height)!,
        WindowWidth: CGFloat = CGFloat(SETTINGS["initialWindowHeight"] as! Int) // do not use WIDTH!
        frame.origin.x = (ScreenHeight / 2 - WindowHeight / 2)
        frame.origin.y = (ScreenWidth / 2 - WindowWidth / 2)
        
        // @froge-xyz Fixed initial window size
        // Issue: #1
        mainWindow.window?.setFrame(frame, display: true)
        
        // set window title
        mainWindow.window?.title = SETTINGS["title"] as! String
        
        // Force some preferences before loading...
        mainWebview.preferences.javaScriptEnabled = true
        mainWebview.preferences.javaScriptCanOpenWindowsAutomatically = true
        mainWebview.preferences.plugInsEnabled = true
    }
    
    func loadUrl(url: String) {
        if ((SETTINGS["showLoadingBar"] as? Bool)!) {
            progressBar.hidden = false
            progressBar.startAnimation(self)
            progressBar.maxValue = 100;
            progressBar.minValue = 1;
            progressBar.incrementBy(24)
        }
        let URL = NSURL(string: url)
        mainWebview.mainFrame.loadRequest(NSURLRequest(URL: URL!))
        
        // Inject Webhooks
        self.injectWebhooks(mainWebview.mainFrame.javaScriptContext)
        self.loopThroughiFrames()
    }
}