//
//  ViewController.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//

import Cocoa
import WebKit
import Foundation

class ViewController: NSViewController, WebFrameLoadDelegate {

    @IBOutlet var mainWindow: NSView!
    @IBOutlet weak var mainWebview: WebView!
    @IBOutlet weak var loadingBar: NSProgressIndicator!
    @IBOutlet weak var launchingLabel: NSTextField!
    
    // TODO: configure your app here
    let SETTINGS: [String: Any]  = [
        
        "url": "http://jsfiddle.net",
        "title": "WebShell",
        "launchingText": "Launching...",
        
        // Note that the window min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
        "minHeight": 640,
        "minWidth": 1000,
        
        "showLoadingBar": true
        
    ]
    
    var firstLoadingStarted = false
    var firstAppear = true
    
    override func viewDidAppear() {
        if(firstAppear){
            initWindow()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let WIDTH: CGFloat = CGFloat(SETTINGS["minWidth"] as! Int),
            HEIGHT: CGFloat = CGFloat(SETTINGS["minHeight"] as! Int)
        
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
        
    }
    
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
    }

}

