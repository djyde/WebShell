//
//  ViewController.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//
//  Wesley de Groot (@wdg), Added Notification and console.log Support

import Cocoa
import WebKit
import Foundation
import AppKit
import AudioToolbox
import IOKit.ps

class ViewController: NSViewController, WebFrameLoadDelegate, WebUIDelegate {

    @IBOutlet var mainWindow: NSView!
    @IBOutlet weak var mainWebview: WebView!
    @IBOutlet weak var loadingBar: NSProgressIndicator!
    @IBOutlet weak var launchingLabel: NSTextField!
    
    // TODO: configure your app here
    let SETTINGS: [String: Any]  = [
        
        // Url to browse to.
        "url": "https://www.google.com",
        
        "title": NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String,
        
        // Do you want to use the document title?
        "useDocumentTitle": true,
        
        // Multilanguage loading text!
        "launchingText": NSLocalizedString("Launching...",comment:"Launching..."),

        // Note that the window min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
        "initialWindowHeight": 640,
        "initialWindowWidth": 1000,
        
        // Open target=_blank in a new screen?
        "openInNewScreen": false,
        
        // Do you want a loading bar?
        "showLoadingBar": true,
        
        "consoleSupport": false
    ]
    
    func webView(sender: WebView!, runJavaScriptAlertPanelWithMessage message: String!, initiatedByFrame frame: WebFrame!) {
        // You could custom the JavaScript alert behavior here
        let alert = NSAlert.init()
        alert.addButtonWithTitle("OK") // message box button text
        alert.messageText = "Message" // message box title
        alert.informativeText = message
        alert.runModal()
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
        
        goHome()
    }
    
    func addObservers(){
        // add menu action observers
        let observers = ["goHome", "reload", "copyUrl", "clearNotificationCount"]
        
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
        
        // @wdg Fixed screen position (now it centers)
        // Issue: #19
        // Note: do not use HEIGHT, WIDTH for some strange reason the window will be positioned 25px from bottom!
        let ScreenHeight:CGFloat = (NSScreen.mainScreen()?.frame.size.width)!,
            WindowHeight:CGFloat = CGFloat(SETTINGS["initialWindowWidth"] as! Int), // do not use HEIGHT!
            ScreenWidth:CGFloat  = (NSScreen.mainScreen()?.frame.size.height)!,
            WindowWidth:CGFloat  = CGFloat(SETTINGS["initialWindowHeight"] as! Int) // do not use WIDTH!
        frame.origin.x = (ScreenHeight/2 - WindowHeight/2)
        frame.origin.y = (ScreenWidth/2  - WindowWidth/2)
        
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
    
    func loadUrl(url: String){
        loadingBar.stopAnimation(self)
        
        let URL = NSURL(string: url)
        mainWebview.mainFrame.loadRequest(NSURLRequest(URL: URL!))
        
        // Inject Webhooks
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

        // Inject Webhooks
        self.injectWebhooks();
    }
    
    // @wdg: Enable file uploads.
    // Issue: #29
    func webView(sender: WebView!, runOpenPanelForFileButtonWithResultListener resultListener: WebOpenPanelResultListener!, allowMultipleFiles: Bool) {
        // Init panel with options
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = allowMultipleFiles
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        
        // On clicked on ok then...
        panel.beginWithCompletionHandler { (result) -> Void in
            // User clicked OK
            if result == NSFileHandlingPanelOKButton {
                
                // make the upload qeue named 'uploadQeue'
                let uploadQeue:NSMutableArray = NSMutableArray()
                for (var i=0; i<panel.URLs.count; i++)
                {
                    // Add to upload qeue, needing relativePath.
                    uploadQeue.addObject(panel.URLs[i].relativePath!)
                }
            
                if (panel.URLs.count == 1) {
                    // One file
                    resultListener.chooseFilename(String(uploadQeue[0]))
                } else {
                    // Multiple files
                    resultListener.chooseFilenames(uploadQeue as [AnyObject])
                }
            }
        }

    }
    
    func webView(sender: WebView!, didReceiveTitle title: String!, forFrame frame: WebFrame!) {
        if(SETTINGS["useDocumentTitle"] as! Bool){
            mainWindow.window?.title = title
        }
    }
    
    func injectWebhooks() {
        // Injecting javascript (via jsContext)
        let jsContext = mainWebview.mainFrame.javaScriptContext
        
        // @wdg Hack URL's if settings is set.
        // Issue: #5
        if((SETTINGS["openInNewScreen"] as? Bool) != false){
            // _blank to external
            // JavaScript -> Select all <a href='...' target='_blank'>
            jsContext.evaluateScript("var links=document.querySelectorAll('a');for(var i=0;i<links.length;i++){if(links[i].target==='_blank'){links[i].addEventListener('click',function () {app.openExternal(this.href);})}}")
        } else {
            // _blank to internal
            // JavaScript -> Select all <a href='...' target='_blank'>
            jsContext.evaluateScript("var links=document.querySelectorAll('a');for(var i=0;i<links.length;i++){if(links[i].target==='_blank'){links[i].addEventListener('click',function () {app.openInternal(this.href);})}}")
        }
        
        // @wdg Add Notification Support
        // Issue: #2
        jsContext.evaluateScript("function Notification(myTitle, options){if(typeof options === 'object'){var body,icon,tag;if (typeof options['body'] !== 'undefined'){body=options['body']}if (typeof options['icon'] !== 'undefined'){Notification.note(myTitle, body, options['icon'])}else{Notification.note(myTitle, body)}}else{if(typeof options === 'string'){Notification.note(myTitle, options)}else{Notification.note(myTitle)}}}Notification.length=1;Notification.permission='granted';Notification.requestPermission=function(callback){if(typeof callback === 'function'){callback();return true}else{return true}};window.Notification=Notification;")
        let myNofification: @convention(block) (NSString!, NSString?, NSString?) -> Void = { (title:NSString!, message:NSString?, icon:NSString?) in
            self.makeNotification(title, message: message!, icon: icon!)
        }
        jsContext.objectForKeyedSubscript("Notification").setObject(unsafeBitCast(myNofification, AnyObject.self), forKeyedSubscript:"note")
        
        // Add console.log ;)
        // Add Console.log (and console.error, and console.warn)
        if(SETTINGS["consoleSupport"] as! Bool){
            jsContext.evaluateScript("var console = {log: function () {var message = '';for (var i = 0; i < arguments.length; i++) {message += arguments[i] + ' '};console.print(message)},warn: function () {var message = '';for (var i = 0; i < arguments.length; i++) {message += arguments[i] + ' '};console.print(message)},error: function () {var message = '';for (var i = 0; i < arguments.length; i++){message += arguments[i] + ' '};console.print(message)}};")
            let logFunction: @convention(block) (NSString!) -> Void = { (message:NSString!) in
                print("JS: \(message)")
            }
            jsContext.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, AnyObject.self), forKeyedSubscript:"print")
        }
        
        // @wdg Add support for target=_blank
        // Issue: #5
        // Fake window.app Library.
        jsContext.evaluateScript("var app={};");
        
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
        
        // navigator.getBattery()
        jsContext.objectForKeyedSubscript("navigator").setObject(BatteryManager.self, forKeyedSubscript: "battery")
        
        jsContext.evaluateScript("window.navigator.getBattery = window.navigator.battery.getBattery;")
        
        // navigator.vibrate
        let vibrateNow: @convention(block) (NSString!) -> Void = { (data:NSString!) in
            self.flashScreen(data)
        }
        jsContext.objectForKeyedSubscript("navigator").setObject(unsafeBitCast(vibrateNow, AnyObject.self), forKeyedSubscript:"vibrate")
    }
    
    
    var notificationCount = 0
    
    func clearNotificationCount(){
        notificationCount = 0
    }
    
    // @wdg Add Notification Support
    // Issue: #2
    func makeNotification (title: NSString, message: NSString, icon: NSString) {
        let notification:NSUserNotification = NSUserNotification() // Set up Notification

        // If has no message (title = message)
        if (message.isEqualToString("undefined")) {
            notification.title = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String // Use App name!
            notification.informativeText = title as String   // Title   = string
        } else {
            notification.title = title as String             // Title   = string
            notification.informativeText = message as String // Message = string
        }

        
        notification.soundName = NSUserNotificationDefaultSoundName // Default sound
        notification.deliveryDate = NSDate(timeIntervalSinceNow: 0) // Now!
        notification.actionButtonTitle = "Close"

        // Notification has a icon, so add it!
        if (!icon.isEqualToString("undefined")) {
            notification.contentImage = NSImage(contentsOfURL: NSURL(string: icon as String)!);
        }
        
        let notificationcenter: NSUserNotificationCenter? = NSUserNotificationCenter.defaultUserNotificationCenter() // Notification centre
        notificationcenter?.scheduleNotification(notification) // Pushing to notification centre
        
        notificationCount++
        
        NSApplication.sharedApplication().dockTile.badgeLabel = String(notificationCount)
    }
    
    // @wdg Add Notification Support
    // Issue: #2
    func flashScreen (data: NSString) {
        print(data)
        if ((Int(data as String)) != nil || data.isEqualToString("undefined")) {
            AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen);
        } else {
            let time:NSArray = (data as String).componentsSeparatedByString(",")
            for(var i = 0; i < time.count; i++) {
                var timeAsInt = NSNumberFormatter().numberFromString(time[i] as! String)
                timeAsInt = Int(timeAsInt!)/100
                NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(timeAsInt!), target: self, selector: Selector("flashScreenNow"), userInfo: nil, repeats: false)
            }
        }
    }
    
    // @wdg Add Notification Support
    // Issue: #2
    func flashScreenNow() {
        AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen);
    }
}
