//
//  WebShellPopupViewController.swift
//  WebShell
//
//  Created by Wesley de Groot on 26-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation

import Cocoa
import WebKit

class WebShellPopupViewController: NSViewController {
    
    @IBOutlet weak var mainWebView: WebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        mainWebView.mainFrame.load(URLRequest(url: URL(string: WebShell().Settings["url"] as! String)!))
    }
    
    override func viewDidAppear() {
        
    }
}
