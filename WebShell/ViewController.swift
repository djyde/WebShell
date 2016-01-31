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
import Darwin
import CoreLocation

// @wdg Clean up code base
// Issue: #43
class ViewController: NSViewController, WebFrameLoadDelegate, WebUIDelegate, WebResourceLoadDelegate, WebPolicyDelegate, CLLocationManagerDelegate {
	
	@IBOutlet var mainWindow: NSView!
	@IBOutlet weak var mainWebview: WebView!
	@IBOutlet weak var launchingLabel: NSTextField!
	@IBOutlet weak var progressBar: NSProgressIndicator!
	var firstLoadingStarted = false
	var firstAppear = true
	var notificationCount = 0
	let locationManager = CLLocationManager()
	
	// TODO: configure your app here
	var SETTINGS: [String: Any] = [
		
		// Url to browse to.
		"url": "https://www.google.com",
		
		"title": NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String,
		
		// Do you want to use the document title? (Default: true)
		"useDocumentTitle": true,
		
		// Multilanguage loading text!
		"launchingText": NSLocalizedString("Launching...", comment: "Launching..."),
		
		// Note that the window min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
		"initialWindowHeight": 640,
		"initialWindowWidth": 1000,
		
		// Open target=_blank in a new screen? (Default: false)
		"openInNewScreen": false,
		
		// Do you want a loading bar? (Default: true)
		"showLoadingBar": true,
		
		// Add console.log support? (Default: false)
		"consoleSupport": false,
		
		// Does the app needs Location support (Default: false)
		// note: if true, then WebShell always uses location, whenever it is used or not
		"needLocation": false,
		
		// run the app in debug mode? (Default: false)
		// will be overridden by xCode (runs with -NSDocumentRevisionsDebugMode YES)
		"debugmode": false
	]
	
	func webView(sender: WebView!, runJavaScriptAlertPanelWithMessage message: String!, initiatedByFrame frame: WebFrame!) {
		let alert = NSAlert.init()
		alert.addButtonWithTitle("OK")
		alert.messageText = "Message"
		alert.informativeText = message
		alert.runModal()
	}
	
	override func viewDidAppear() {
		if (firstAppear) {
			initWindow()
		}
	}
	
	// @wdg Possible fix for Mavericks
	// Issue: #18
	override func awakeFromNib() {
		if (!NSViewController().respondsToSelector(Selector("viewWillAppear"))) {
			// OS X 10.9
			if (firstAppear) {
				initWindow()
			}
			
			mainWebview.UIDelegate = self
			mainWebview.resourceLoadDelegate = self
			
			checkSettings()
			addObservers()
			initSettings()
			goHome()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mainWebview.UIDelegate = self
		mainWebview.resourceLoadDelegate = self
		
		checkSettings()
		addObservers()
		initSettings()
		goHome()
	}
	
	// webview settings
	func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
		// @wdg: Better progress indicator | Issue: #37
		if ((SETTINGS["showLoadingBar"] as? Bool)!) {
			progressBar.startAnimation(self)
			progressBar.maxValue = 100;
			progressBar.minValue = 1;
			progressBar.incrementBy(24)
		}
		
		if (!firstLoadingStarted) {
			firstLoadingStarted = true
			launchingLabel.hidden = false
		}
	}
	
	// @wdg: Better progress indicator
	// Issue: #37
	func webView(sender: WebView!, willPerformClientRedirectToURL URL: NSURL!, delay seconds: NSTimeInterval, fireDate date: NSDate!, forFrame frame: WebFrame!) {
		if ((SETTINGS["showLoadingBar"] as? Bool)!) {
			progressBar.hidden = false
			progressBar.startAnimation(self)
			progressBar.maxValue = 100;
			progressBar.minValue = 1;
			progressBar.incrementBy(24)
		}
	}
	
	// @wdg: Better progress indicator
	// Issue: #37
	func webView(webView: WebView!, decidePolicyForMIMEType type: String!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
		if ((SETTINGS["showLoadingBar"] as? Bool)!) {
			progressBar.hidden = false
			progressBar.startAnimation(self)
			progressBar.maxValue = 100;
			progressBar.minValue = 1;
			progressBar.incrementBy(24)
		}
	}
	
	// @wdg: Better progress indicator
	// Issue: #37
	func webView(webView: WebView!, didFailLoadWithError error: NSError) {
		progressBar.incrementBy(50)
		progressBar.stopAnimation(self)
		progressBar.hidden = true
		progressBar.doubleValue = 1;
	}
	
	// @wdg: Better progress indicator
	// Issue: #37
	func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
		progressBar.incrementBy(50)
		progressBar.stopAnimation(self)
		progressBar.hidden = true // Hide after we're done.
		progressBar.doubleValue = 1;
		if (!launchingLabel.hidden) {
			launchingLabel.hidden = true
		}
		
		// Inject Webhooks
		self.injectWebhooks(mainWebview.mainFrame.javaScriptContext)
		self.loopThroughiFrames()
		
		// @wdg Add location support
		// Issue: #41
		if (SETTINGS["needLocation"] as! Bool) {
			self.websiteWantsLocation()
		} else {
			self.locationInjector(false) // Says i don't have a location!
		}
	}
	
	func webView(sender: WebView!, didReceiveTitle title: String!, forFrame frame: WebFrame!) {
		if (SETTINGS["useDocumentTitle"] as! Bool) {
			mainWindow.window?.title = title
		}
	}
}
