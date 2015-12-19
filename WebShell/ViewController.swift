//
//  ViewController.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015年 RandyLu. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBOutlet var mainWindow: NSView!
    @IBOutlet weak var mainWebview: WebView!
    
    
    // TODO: replace your url here
    let urlString = "http://baidu.com"
    
    // TODO: set window size
    // * Note that default min width is 1000 and min height is 640. You could change them in Main.storyboard.
    let WIDTH: CGFloat = 1000,
    HEIGHT: CGFloat = 640
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWindowSize()
        
        loadUrl(urlString)
    }
    
    func setWindowSize(){
        var frame: NSRect = mainWindow.frame
        
        frame.size.width = WIDTH
        frame.size.height = HEIGHT
        
        mainWindow.frame = frame
    }
    
    func loadUrl(url: String){
        let URL = NSURL(string: url)
        mainWebview.mainFrame.loadRequest(NSURLRequest(URL: URL!))
    }



}

