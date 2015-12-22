//
//  ViewController.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//
//  Wesley de Groot 21-DEC-2015, Added Notification and console.log Support

import Cocoa
import WebKit
import Foundation
import AppKit

class ViewController: NSViewController, WebFrameLoadDelegate, WebUIDelegate {

    @IBOutlet var mainWindow: NSView!
    @IBOutlet weak var mainWebview: WebView!
    @IBOutlet weak var loadingBar: NSProgressIndicator!
    @IBOutlet weak var launchingLabel: NSTextField!
    
    // TODO: configure your app here
    let SETTINGS: [String: Any]  = [
        
//        "url": "http://baidu.com",
        "url": "https://www.wdgwv.com/localNotificationExample", // Basic Notification sender thing. (local notifications ofc). (can be used for testing)
        
        "title": NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String, // App name is nicer."WebShell",
        "useDocumentTitle": true,
        
        "launchingText": "Launching...",
        
        // Note that the window min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
        "initialWindowHeight": 640,
        "initialWindowWidth": 1000,
        
        // Open target=_blank in a new screen?
        "openInNewScreen": false,
        
        "showLoadingBar": true
        
    ]
    
    func webView(sender: WebView!, runJavaScriptAlertPanelWithMessage message: String!, initiatedByFrame frame: WebFrame!) {
        // You could custom the JavaScript alert behavior here
        let alert = NSAlert.init()
        alert.addButtonWithTitle("OK") // message box button text
        alert.messageText = "Message" // message box title
        alert.informativeText = message
        alert.runModal()
    }
    
    func makeNotification (message: NSString) {
        let notification:NSUserNotification = NSUserNotification() // Set up Notification
        notification.title = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String // Use App name!
        notification.informativeText = message as String // Message = string
        notification.soundName = NSUserNotificationDefaultSoundName // Default sound
        notification.deliveryDate = NSDate(timeIntervalSinceNow: 0) // Now!
        let notificationcenter: NSUserNotificationCenter? = NSUserNotificationCenter.defaultUserNotificationCenter() // Notification centre
        notificationcenter!.scheduleNotification(notification) // Pushing to notification centre
    }

    var firstLoadingStarted = false
    var firstAppear = true
    
    override func viewDidAppear() {
        if(firstAppear){
            initWindow()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainWebview.UIDelegate = self
        
        addObservers()
        
        initSettings()
        
        loadUrl((SETTINGS["url"] as? String)!)
    }
    
    func addObservers(){
        // add menu action observers
        let observers = ["goHome", "reload", "copyUrl"]
        
        for observer in observers{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString(observer), name: observer, object: nil)
        }
    }
    
    func goHome(){
        loadUrl((SETTINGS["url"] as? String)!)
    }
    
    func reload(){
        let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.URL?.absoluteString)!
        loadUrl(currentUrl)
    }
    
    func copyUrl(){
        let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.URL?.absoluteString)!
        let clipboard: NSPasteboard = NSPasteboard.generalPasteboard()
        clipboard.clearContents()
        
        clipboard.setString(currentUrl, forType: NSStringPboardType)
    }
    
    func initSettings(){
        // controll the progress bar
        if(!(SETTINGS["showLoadingBar"] as? Bool)!){
            loadingBar.hidden = true
        }
        
        // set launching text
        launchingLabel.stringValue = (SETTINGS["launchingText"] as? String)!
    }
    
    func initWindow(){
        
        firstAppear = false
        
        // set window size
        var frame: NSRect = mainWindow.frame
        
        let WIDTH: CGFloat = CGFloat(SETTINGS["initialWindowWidth"] as! Int),
            HEIGHT: CGFloat = CGFloat(SETTINGS["initialWindowHeight"] as! Int)
        
        frame.size.width = WIDTH
        frame.size.height = HEIGHT
        
        mainWindow.frame = frame
        
        // set window title
        mainWindow.window!.title = SETTINGS["title"] as! String
    }
    
    func loadUrl(url: String){
        loadingBar.stopAnimation(self)
        
        let URL = NSURL(string: url)
        mainWebview.mainFrame.loadRequest(NSURLRequest(URL: URL!))
        
        self.injectWebhooks()
    }
    
    
    // webview settings
    func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
        loadingBar.startAnimation(self)
        
        if(!firstLoadingStarted){
            firstLoadingStarted = true
            launchingLabel.hidden = false
        }
    }
    
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        loadingBar.stopAnimation(self)
        
        if(!launchingLabel.hidden){
            launchingLabel.hidden = true
        }

        // Webhooks
        self.injectWebhooks();
    }
    
    func webView(sender: WebView!, didReceiveTitle title: String!, forFrame frame: WebFrame!) {
        if(SETTINGS["useDocumentTitle"] as! Bool){
            mainWindow.window?.title = title
        }
    }
    
    func injectWebhooks() {
        // Hack URL's if settings is set.
        if((SETTINGS["openInNewScreen"] as? Bool) != false){
            // _blank to external
            mainWebview.mainFrame.javaScriptContext.evaluateScript(
                // JavaScript -> Select all <a href='...' target='_blank'>
                "var links=document.querySelectorAll('a');" +
                    "for(var i=0;i<links.length;i++){" +
                    "  if(links[i].target==='_blank'){" +
                    "    links[i].addEventListener('click',function () {" +
                    "      app.openExternal(this.href);" +
                    "    })" +
                    "  }" +
                "}"
            )
        } else {
            // _blank to internal
            mainWebview.mainFrame.javaScriptContext.evaluateScript(
                // JavaScript -> Select all <a href='...' target='_blank'>
                "var links=document.querySelectorAll('a');" +
                    "for(var i=0;i<links.length;i++){" +
                    "  if(links[i].target==='_blank'){" +
                    "    links[i].addEventListener('click',function () {" +
                    "      app.openInternal(this.href);" +
                    "    })" +
                    "  }" +
                "}"
            )
        }
        
        // Injecting javascript (via jsContext)
        let jsContext = mainWebview.mainFrame.javaScriptContext
        
        // Add Notification Support
        jsContext.evaluateScript(
            "function Notification (myMessage){" +
            "  Notification.note(myMessage)" +
            "}" +
            "Notification.length=1;" +
            "Notification.permission = 'granted';" +
            "Notification.requestPermission = function (callback) {" +
            "  if (typeof callback === 'function') {" +
            "    callback();" +
            "    return true" +
            "  } else {" +
            "    return true" +
            "  }" +
            "};" +
            "window.Notification=Notification;"
        )
        let myNofification: @convention(block) (NSString!) -> Void = { (message:NSString!) in
            self.makeNotification(message)
        }
        jsContext.objectForKeyedSubscript("Notification").setObject(unsafeBitCast(myNofification, AnyObject.self), forKeyedSubscript:"note")
        
        // Add console.log ;)
        jsContext.evaluateScript(
            // Add Console.log (and console.error, and console.warn)
            "var console = {" +
            "  log: function () {" +
            "    var message = '';" +
            "    for (var i = 0; i < arguments.length; i++) {" +
            "      message += arguments[i] + ' '" +
            "    };" +
            "    console.print(message)" +
            "  }," +
            "  warn: function () {" +
            "    var message = '';" +
            "    for (var i = 0; i < arguments.length; i++) {" +
            "      message += arguments[i] + ' '" +
            "    };" +
            "    console.print(message)" +
            "  }," +
            "  error: function () {" +
            "    var message = '';" +
            "    for (var i = 0; i < arguments.length; i++) {" +
            "      message += arguments[i] + ' '" +
            "    };" +
            "    console.print(message)" +
            "  }" +
            "};"
        )
        let logFunction: @convention(block) (NSString!) -> Void = { (message:NSString!) in
            print("JS: \(message)")
        }
        jsContext.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, AnyObject.self), forKeyedSubscript:"print")
        
        // Add support for target=_blank
        jsContext.evaluateScript(
            // Fake window.app Library.
            "var app={};"
        );
        
        // _blank external
        let openInBrowser: @convention(block) (NSString!) -> Void = { (url:NSString!) in
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: (url as String))!)
        }
        
        // _blank internal
        let openNow: @convention(block) (NSString!) -> Void = { (url:NSString!) in
            self.loadUrl((url as String))
        }
        // _blank external
        jsContext.objectForKeyedSubscript("app").setObject(unsafeBitCast(openInBrowser, AnyObject.self), forKeyedSubscript:"openExternal")
        
        // _blank internal
        jsContext.objectForKeyedSubscript("app").setObject(unsafeBitCast(openNow, AnyObject.self), forKeyedSubscript:"openInternal")
    }
}
