//
//  WSViewController.swift
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
import Darwin
import CoreLocation

// @wdg Clean up code base
// Issue: #43
class WSViewController: NSViewController, WebFrameLoadDelegate, WebUIDelegate, WebResourceLoadDelegate, WebPolicyDelegate, CLLocationManagerDelegate, WebDownloadDelegate, NSURLDownloadDelegate, WebEditingDelegate {
    
	@IBOutlet var mainWindow: NSView!
	@IBOutlet weak var mainWebview: WebView!
	@IBOutlet weak var launchingLabel: NSTextField!
	@IBOutlet weak var progressBar: NSProgressIndicator!
    
    var settings = Settings.shared
	var firstLoadingStarted = false
	var firstAppear = true
	var notificationCount = 0
	var lastURL:URL!
    var IElement = NSMenuItem()
	let locationManager = CLLocationManager()
    var MustCloseWindow = true
    var WSgestureLog: [CGFloat] = [0, 0]
    var twoFingersTouches: [String: NSTouch]?
	
	override func viewDidAppear() {
		if (firstAppear) {
			initWindow()
		}
	}
	
	// @wdg Possible fix for Mavericks
	// Issue: #18
	override func awakeFromNib() {
		// if (![self respondsToSelector:@selector(viewWillAppear)]) {
		
		if (!NSViewController().responds(to: #selector(NSViewController.viewWillAppear))) {
			checkSettings()
			
			let myPopup: NSAlert = NSAlert()
			myPopup.messageText = "Hello!"
			myPopup.informativeText = "You are running mavericks?"
			myPopup.alertStyle = NSAlert.Style.informational
			myPopup.addButton(withTitle: "Yes")
			myPopup.addButton(withTitle: "No")
			
			let res = myPopup.runModal()
			
			
			print("MAVERICKS \(res)")
			
			// OS X 10.9
			if (firstAppear) {
				initWindow()
			}
			
			mainWebview.uiDelegate = self
			mainWebview.resourceLoadDelegate = self
			mainWebview.downloadDelegate = self
			mainWebview.editingDelegate = self
			mainWebview.policyDelegate = self
			//WebUIDelegate
			
			addObservers()
			initSettings()
			loadUrl(settings.startURL())
			WSMediaLoop(self)
			WSinitSwipeGestures()
		}
	}
	
	override func viewDidLoad() {
		checkSettings()
		//self.view = goodView()
		super.viewDidLoad()
		
		mainWebview.uiDelegate = self
		mainWebview.resourceLoadDelegate = self
		mainWebview.downloadDelegate = self
		mainWebview.editingDelegate = self
		mainWebview.policyDelegate = self
		
		//        WebShellSettings["WSMW"] = mainWebview;
		
		checkSettings()
		addObservers()
		initSettings()
		loadUrl(settings.startURL())
		WSMediaLoop(self)
		WSinitSwipeGestures()
	}
}
