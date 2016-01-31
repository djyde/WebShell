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

class ViewController: NSViewController, WebFrameLoadDelegate, WebUIDelegate, WebResourceLoadDelegate, WebPolicyDelegate, CLLocationManagerDelegate {
	
	@IBOutlet var mainWindow: NSView!
	@IBOutlet weak var mainWebview: WebView!
	@IBOutlet weak var launchingLabel: NSTextField!
	@IBOutlet weak var progressBar: NSProgressIndicator!
	
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
		// You could custom the JavaScript alert behavior here
		let alert = NSAlert.init()
		alert.addButtonWithTitle("OK") // message box button text
		alert.messageText = "Message" // message box title
		alert.informativeText = message
		alert.runModal()
	}
	
	var firstLoadingStarted = false
	var firstAppear = true
	var notificationCount = 0
	// @wdg Add location support
	// Issue: #41
	let locationManager = CLLocationManager()
	
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
        progressBar.doubleValue=1;
    }
    
	func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
		// @wdg: Better progress indicator | Issue: #37
		progressBar.incrementBy(50)
		progressBar.stopAnimation(self)
		progressBar.hidden = true // Hide after we're done.
        progressBar.doubleValue=1;
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
		panel.beginWithCompletionHandler {(result) -> Void in
			// User clicked OK
			if result == NSFileHandlingPanelOKButton {
				
				// make the upload qeue named 'uploadQeue'
				let uploadQeue: NSMutableArray = NSMutableArray()
				for (var i = 0; i < panel.URLs.count; i++)
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
		if (SETTINGS["useDocumentTitle"] as! Bool) {
			mainWindow.window?.title = title
		}
	}
	
	// @wdg possible fix for the iframes shizzle
	// Issue: #23 (not fixed)
	func loopThroughiFrames() {
		if (mainWebview.subviews.count > 0) {
			// We've got subViews!
			
			if (mainWebview.subviews[0].subviews.count > 0) {
				// mainWebview.subviews[0] = WebFrameView
				
				let goodKids = mainWebview.subviews[0].subviews[0]
				// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView (= goodKids)
				
				var children = goodKids.subviews[0]
				// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView.subviews[0] = WebClipView (= children)
				
				// We need > 0 subviews here, otherwise don't add them. and the script will continue
				if children.subviews.count > 0 {
					// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView.subviews[0] = WebClipView.subviews[0] = WebHTMLView
					children = goodKids.subviews[0].subviews[0]
				}
				
				// Finally. parsing those good old iframes
				// We don't check them for iframes, somewhere the fun must be ended.
				for child in children.subviews {
					// mainWebview.subviews[0] = WebFrameView.subviews[0] = WebDynamicScrollBarsView.subviews[0] = WebClipView.subviews[0] = WebHTMLView.subviews[x] = WebFrameView (Finally) (name = child)
					if (child.isKindOfClass(WebFrameView)) {
						let frame: NSView = child
						let context: JSContext = frame.webFrame.javaScriptContext
						
						injectWebhooks(context)
					}
				}
			}
		}
	}
	
	func injectWebhooks(jsContext: JSContext!) {
		// Injecting javascript (via jsContext)
		
		// @wdg Hack URL's if settings is set.
		// Issue: #5
		if ((SETTINGS["openInNewScreen"] as? Bool) != false) {
			// _blank to external
			// JavaScript -> Select all <a href='...' target='_blank'>
			jsContext.evaluateScript("var links=document.querySelectorAll('a');for(var i=0;i<links.length;i++){if(links[i].target==='_blank'){links[i].addEventListener('click',function () {app.openExternal(this.href);})}}")
		} else {
			// _blank to internal
			// JavaScript -> Select all <a href='...' target='_blank'>
			jsContext.evaluateScript("var links=document.querySelectorAll('a');for(var i=0;i<links.length;i++){if(links[i].target==='_blank'){links[i].addEventListener('click',function () {app.openInternal(this.href);})}}")
		}
		
		// @wdg Add Notification Support
		// Issue: #2, #35, #38 (webkitNotification)
		jsContext.evaluateScript("function Notification(myTitle, options){if(typeof options === 'object'){var body,icon,tag;if (typeof options['body'] !== 'undefined'){body=options['body']}if (typeof options['icon'] !== 'undefined'){Notification.note(myTitle, body, options['icon'])}else{Notification.note(myTitle, body)}}else{if(typeof options === 'string'){Notification.note(myTitle, options)}else{Notification.note(myTitle)}}}Notification.length=1;Notification.permission='granted';Notification.requestPermission=function(callback){if(typeof callback === 'function'){callback('granted');}else{return 'granted'}};window.Notification=Notification;window.webkitNotification=Notification;")
		let myNofification: @convention(block)(NSString!, NSString?, NSString?) -> Void = {(title: NSString!, message: NSString?, icon: NSString?) in
			self.makeNotification(title, message: message!, icon: icon!)
		}
		jsContext.objectForKeyedSubscript("Notification").setObject(unsafeBitCast(myNofification, AnyObject.self), forKeyedSubscript: "note")
		
		// Add console.log ;)
		// Add Console.log (and console.error, and console.warn)
		if (SETTINGS["consoleSupport"] as! Bool) {
			jsContext.evaluateScript("var console = {log: function () {var message = '';for (var i = 0; i < arguments.length; i++) {message += arguments[i] + ' '};console.print(message)},warn: function () {var message = '';for (var i = 0; i < arguments.length; i++) {message += arguments[i] + ' '};console.print(message)},error: function () {var message = '';for (var i = 0; i < arguments.length; i++){message += arguments[i] + ' '};console.print(message)}};")
			let logFunction: @convention(block)(NSString!) -> Void = {(message: NSString!) in
				print("JS: \(message)")
			}
			jsContext.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, AnyObject.self), forKeyedSubscript: "print")
		}
		
		// @wdg Add support for target=_blank
		// Issue: #5
		// Fake window.app Library.
		jsContext.evaluateScript("var app={};") ;
		
		// _blank external
		let openInBrowser: @convention(block)(NSString!) -> Void = {(url: NSString!) in
			NSWorkspace.sharedWorkspace().openURL(NSURL(string: (url as String))!)
		}
		
		// _blank internal
		let openNow: @convention(block)(NSString!) -> Void = {(url: NSString!) in
			self.loadUrl((url as String))
		}
		// _blank external
		jsContext.objectForKeyedSubscript("app").setObject(unsafeBitCast(openInBrowser, AnyObject.self), forKeyedSubscript: "openExternal")
		
		// _blank internal
		jsContext.objectForKeyedSubscript("app").setObject(unsafeBitCast(openNow, AnyObject.self), forKeyedSubscript: "openInternal")
		
		// @wdg Add Print Support
		// Issue: #39
		// window.print()
		let printMe: @convention(block)(NSString?) -> Void = {(url: NSString?) in self.printThisPage()}
		jsContext.objectForKeyedSubscript("window").setObject(unsafeBitCast(printMe, AnyObject.self), forKeyedSubscript: "print")
		
		// navigator.getBattery()
		jsContext.objectForKeyedSubscript("navigator").setObject(BatteryManager.self, forKeyedSubscript: "battery")
		
		jsContext.evaluateScript("window.navigator.getBattery = window.navigator.battery.getBattery;")
		
		// navigator.vibrate
		let vibrateNow: @convention(block)(NSString!) -> Void = {(data: NSString!) in
			self.flashScreen(data)
		}
		jsContext.objectForKeyedSubscript("navigator").setObject(unsafeBitCast(vibrateNow, AnyObject.self), forKeyedSubscript: "vibrate")
		
		// @wdg Add localstorage Support
		// Issue: #25
		let saveToLocal: @convention(block)(NSString!, NSString!) -> Void = {(key: NSString!, value: NSString!) in
			let host: String = (self.mainWebview.mainFrame.dataSource?.request.URL?.host)!
			let newKey = "WSLS:\(host):\(key)"
			
			NSUserDefaults.standardUserDefaults().setValue(value, forKey: newKey)
		}
		
		let getFromLocal: @convention(block)(NSString!) -> String = {(key: NSString!) in
			let host: String = (self.mainWebview.mainFrame.dataSource?.request.URL?.host)!
			let newKey = "WSLS:\(host):\(key)"
			let val = NSUserDefaults.standardUserDefaults().valueForKey(newKey as String)
			
			if let myVal = val as? String {
				return String(myVal)
			}
			else {
				return "null"
			}
		}
		
		jsContext.objectForKeyedSubscript("localStorage").setObject(unsafeBitCast(saveToLocal, AnyObject.self), forKeyedSubscript: "setItem")
		jsContext.objectForKeyedSubscript("localStorage").setObject(unsafeBitCast(getFromLocal, AnyObject.self), forKeyedSubscript: "getItem")
		
	}
	
	// Quit the app (there must be a better way)
	func Quit(sender: AnyObject) {
		exit(0)
	}
	
	
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
	
	// Function to call for the window.open (popup)
	func openNewWindow(url: String, height: String, width: String) -> Void {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
				dispatch_async(dispatch_get_main_queue(), {() -> Void in
						
						// TODO: This one freezes our main window, even in the qeue
						// TODO: Hide this window
						
						let task = NSTask()
						task.launchPath = Process.arguments[0]
						
						if (self.SETTINGS["debugmode"] as! Bool) {
							// With debug mode
							task.arguments = ["-NSDocumentRevisionsDebugMode", "YES", "-url", url, "-height", height, "-width", width]
						} else {
							// Production mode
							task.arguments = ["-url", url, "-height", height, "-width", width]
						}
						
						print("Running: \(Process.arguments[0]) -url \"\(url)\" second-argument")
						
						let pipe = NSPipe()
						task.standardOutput = pipe
						task.launch()
						
						let data = pipe.fileHandleForReading.readDataToEndOfFile()
						
						let output: String = String(data: data, encoding: NSUTF8StringEncoding)!
						print(output)
					})
			})
	}
			
	// @wdg Add Localstorage Support
	// Issue: #25
	func resetLocalStorage(Sender: AnyObject = "") -> Void {
		NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
	}
	
	func noop(ob: Any...) -> Void {}
	
	func delay(delay: Double, _ closure: () -> ()) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
	}
}
