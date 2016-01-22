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

class ViewController: NSViewController, WebFrameLoadDelegate, WebUIDelegate, WebResourceLoadDelegate, WebPolicyDelegate {
	
	@IBOutlet var mainWindow: NSView!
	@IBOutlet weak var mainWebview: WebView!
	@IBOutlet weak var loadingBar: NSProgressIndicator!
	@IBOutlet weak var launchingLabel: NSTextField!
	
	// TODO: configure your app here
	var SETTINGS: [String: Any] = [
		
		// Url to browse to.
		"url": "https://www.google.com",
		
		"title": NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String,
		
		// Do you want to use the document title?
		"useDocumentTitle": true,
		
		// Multilanguage loading text!
		"launchingText": NSLocalizedString("Launching...", comment: "Launching..."),
		
		// Note that the window min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
		"initialWindowHeight": 640,
		"initialWindowWidth": 1000,
		
		// Open target=_blank in a new screen?
		"openInNewScreen": false,
		
		// Do you want a loading bar?
		"showLoadingBar": true,
		
		// Add console.log support?
		"consoleSupport": false,
		
		// run the app in debug mode?
		// will be overridden by xCode (runs with -NSDocumentRevisionsDebugMode YES)
		"debugmode": false,
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
			loadingBar.hidden = true
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
		loadingBar.stopAnimation(self)
		
		let URL = NSURL(string: url)
		mainWebview.mainFrame.loadRequest(NSURLRequest(URL: URL!))
		
		// Inject Webhooks
		self.injectWebhooks(mainWebview.mainFrame.javaScriptContext)
		self.loopThroughiFrames()
	}
	
	
	// webview settings
	func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
		loadingBar.startAnimation(self)
		
		if (!firstLoadingStarted) {
			firstLoadingStarted = true
			launchingLabel.hidden = false
		}
	}
	
	func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
		loadingBar.stopAnimation(self)
		
		if (!launchingLabel.hidden) {
			launchingLabel.hidden = true
		}
		
		// Inject Webhooks
		self.injectWebhooks(mainWebview.mainFrame.javaScriptContext)
		self.loopThroughiFrames()
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
	}
	
	// Quit the app (there must be a better way)
	func Quit(sender: AnyObject) {
		exit(0)
	}
	
	// Edit contextmenu...
	func webView(sender: WebView!, contextMenuItemsForElement element: [NSObject : AnyObject]!, var defaultMenuItems: [AnyObject]!) -> [AnyObject]! {
		// Add debug menu. (if enabled)
		if (SETTINGS["debugmode"] as! Bool) {
			let debugMenu = NSMenu(title: "Debug")
			debugMenu.addItem(NSMenuItem.init(title: "Open New window", action: Selector("_debugNewWindow:"), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Print arguments", action: Selector("_debugDumpArguments:"), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Open URL", action: Selector("_openURL:"), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Report an issue on this page", action: Selector("_reportThisPage:"), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Print this page", action: Selector("printThisPage:"), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.separatorItem())
			debugMenu.addItem(NSMenuItem.init(title: "Fire some random Notifications", action: Selector("__sendNotifications:"), keyEquivalent: ""))
			
			let item = NSMenuItem.init(title: "Debug", action: Selector("_doNothing:"), keyEquivalent: "")
			item.submenu = debugMenu
			
			defaultMenuItems.append(item)
		}
		
		defaultMenuItems.append(NSMenuItem.separatorItem())
		defaultMenuItems.append(NSMenuItem.init(title: "Quit", action: Selector("Quit:"), keyEquivalent: ""))
		
		return defaultMenuItems
	}
	
	// Debug: doNothing
	func _doNothing(Sender: AnyObject) {
		// _doNothing
	}
	
	// Debug: Open new window
	func _debugNewWindow(Sender: AnyObject) {
		openNewWindow("https://www.google.nl/search?client=safari&rls=en&q=new+window&ie=UTF-8&oe=UTF-8&gws_rd=cr&ei=_8eKVs2WFIbFPd7Sr_gN", height: "0", width: "0")
	}
	
	// Debug: Print arguments
	func _debugDumpArguments(Sender: AnyObject) {
		print(Process.arguments)
	}
	
	// Debug: Send notifications (10)
	func __sendNotifications(Sender: AnyObject) {
		// Minimize app
		NSApplication.sharedApplication().keyWindow?.miniaturize(self)
		
		// Fire 10 Notifications
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(05), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(15), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(25), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(35), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(45), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(55), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(65), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(75), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(85), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(95), target: self, selector: Selector("___sendNotifications"), userInfo: nil, repeats: false)
	}
	
	// Debug: Send notifications (10): Real sending.
	func ___sendNotifications() {
		// Minimize app
		if (NSApplication.sharedApplication().keyWindow?.miniaturized == false) {
			NSApplication.sharedApplication().keyWindow?.miniaturize(self)
		}
		
		// Send Actual notification.
		makeNotification("Test Notification", message: "Hi!", icon: "https://camo.githubusercontent.com/ee999b2d8fa5413229fdc69e0b53144f02b7b840/687474703a2f2f376d6e6f79372e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7765627368656c6c2f6c6f676f2e706e673f696d616765566965772f322f772f313238")
	}
	
	func _openURL(Sender: AnyObject) {
		let msg = NSAlert()
		msg.addButtonWithTitle("OK") // 1st button
		msg.addButtonWithTitle("Cancel") // 2nd button
		msg.messageText = "URL"
		msg.informativeText = "Where you need to go?"
		
		let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
		txt.stringValue = "http://"
		
		msg.accessoryView = txt
		let response: NSModalResponse = msg.runModal()
		
		if (response == NSAlertFirstButtonReturn) {
			self.loadUrl(txt.stringValue)
		}
	}
	
	func _reportThisPage(Sender: AnyObject) {
		let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.URL?.absoluteString)!
		let host: String = (mainWebview.mainFrame.dataSource?.request.URL?.host)!
		
		let issue: String = String("Problem loading \(host)").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!.stringByReplacingOccurrencesOfString("&", withString: "%26")
		var body: String = (String("There is a problem loading \(currentUrl)").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())?.stringByReplacingOccurrencesOfString("&", withString: "%26"))!
		body.appendContentsOf("%0D%0AThe%20problem%20is%3A%0D%0A...")
		
		let url: String = "https://github.com/djyde/WebShell/issues/new?title=\(issue)&body=\(body)"
		
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: (url as String))!)
	}
	
	// @wdg Add Print Support
	// Issue: #39
	func printThisPage() {
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
	func openNewWindow(url: String, height: String, width: String) {
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
	
	// @wdg Override settings via commandline
	// .... Used for popups, and debug options.
	func checkSettings() {
		// Need to overwrite settings?
		if (Process.argc > 0) {
			for (var i = 1; i < Int(Process.argc) ; i = i + 2) {
				if ((String(Process.arguments[i])) == "-NSDocumentRevisionsDebugMode") {
					if ((String(Process.arguments[i + 1])) == "YES") {
						SETTINGS["debugmode"] = true
						SETTINGS["consoleSupport"] = true
					}
				}
				
				if ((String(Process.arguments[i])).uppercaseString == "-DEBUG") {
					if ((String(Process.arguments[i + 1])).uppercaseString == "YES" || (String(Process.arguments[i + 1])).uppercaseString == "true") {
						SETTINGS["debugmode"] = true
						SETTINGS["consoleSupport"] = true
					}
				}
				
				if ((String(Process.arguments[i])) == "-dump-args") {
					self._debugDumpArguments("")
				}
				
				if ((String(Process.arguments[i])) == "-url") {
					SETTINGS["url"] = String(Process.arguments[i + 1])
				}
				
				if ((String(Process.arguments[i])) == "-height") {
					SETTINGS["initialWindowHeight"] = (Int(Process.arguments[i + 1]) > 30) ? Int(Process.arguments[i + 1]) : Int(30)
				}
				
				if ((String(Process.arguments[i])) == "-width") {
					SETTINGS["initialWindowWidth"] = (Int(Process.arguments[i + 1]) > 30) ? Int(Process.arguments[i + 1]) : Int(30)
				}
			}
		}
		
		initWindow()
	}
	
	func clearNotificationCount() {
		notificationCount = 0
	}
	
	// @wdg Add Notification Support
	// Issue: #2
	func makeNotification(title: NSString, message: NSString, icon: NSString) {
		let notification: NSUserNotification = NSUserNotification() // Set up Notification
		
		// If has no message (title = message)
		if (message.isEqualToString("undefined")) {
			notification.title = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String // Use App name!
			notification.informativeText = title as String // Title   = string
		} else {
			notification.title = title as String // Title   = string
			notification.informativeText = message as String // Message = string
		}
		
		
		notification.soundName = NSUserNotificationDefaultSoundName // Default sound
		notification.deliveryDate = NSDate(timeIntervalSinceNow: 0) // Now!
		notification.actionButtonTitle = "Close"
		
		// Notification has a icon, so add it!
		if (!icon.isEqualToString("undefined")) {
			notification.contentImage = NSImage(contentsOfURL: NSURL(string: icon as String)!) ;
		}
		
		let notificationcenter: NSUserNotificationCenter? = NSUserNotificationCenter.defaultUserNotificationCenter() // Notification centre
		notificationcenter?.scheduleNotification(notification) // Pushing to notification centre
		
		notificationCount++
		
		NSApplication.sharedApplication().dockTile.badgeLabel = String(notificationCount)
	}
	
	// @wdg Add Notification Support
	// Issue: #2
	func flashScreen(data: NSString) {
		if ((Int(data as String)) != nil || data.isEqualToString("undefined")) {
			AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen) ;
		} else {
			let time: NSArray = (data as String).componentsSeparatedByString(",")
			for (var i = 0; i < time.count; i++) {
				var timeAsInt = NSNumberFormatter().numberFromString(time[i] as! String)
				timeAsInt = Int(timeAsInt!) / 100
				NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(timeAsInt!), target: self, selector: Selector("flashScreenNow"), userInfo: nil, repeats: false)
			}
		}
	}
	
	// @wdg Add Notification Support
	// Issue: #2
	func flashScreenNow() {
		AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen) ;
	}
}
