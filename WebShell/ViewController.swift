//
//  ViewController.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015年 RandyLu. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WebFrameLoadDelegate {

    @IBOutlet var mainWindow: NSView!
    @IBOutlet weak var mainWebview: WebView!
    @IBOutlet weak var loadingBar: NSProgressIndicator!
    @IBOutlet weak var launchingLabel: NSTextField!
    
    // TODO: configure your app here
    let SETTINGS: [String: Any]  = [
        
        "url": "https://jsfiddle.net",
        "title": "WebShell",
        
        // Note that the window  min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
        "height": 640,
        "width": 1000,
        
        "showLoadingBar": true
    ]
    
    var firstLoadingStarted = false
    
    override func viewDidAppear() {
        initWindow()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(!(SETTINGS["showLoadingBar"] as? Bool)!){
            // hide the loading bar
            loadingBar.hidden = true
        }
        
        loadUrl((SETTINGS["url"] as? String)!)
    }
    
    func initWindow(){
        
        // set window size
        var frame: NSRect = mainWindow.frame
        
        let WIDTH: CGFloat = CGFloat(SETTINGS["width"] as! Int),
            HEIGHT: CGFloat = CGFloat(SETTINGS["height"] as! Int)
        
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
        // loading start
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

