//
//  WebShellDebug.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit

// @wdg Add Debug support
// Issue: None.
// This extension will handle the Debugging options.
extension ViewController {

	// @wdg Override settings via commandline
	// .... Used for popups, and debug options.
	func checkSettings() -> Void {
		// Need to overwrite settings?
		if (Process.argc > 0) {
			for i in 1.stride(to: Int(Process.argc), by: 2) {
//            for (var i = 1; i < Int(Process.argc) ; i = i + 2) {
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
					SETTINGS["initialWindowHeight"] = (Int(Process.arguments[i + 1]) > 250) ? Int(Process.arguments[i + 1]) : Int(250)
				}

				if ((String(Process.arguments[i])) == "-width") {
					SETTINGS["initialWindowWidth"] = (Int(Process.arguments[i + 1]) > 250) ? Int(Process.arguments[i + 1]) : Int(250)
				}
			}
		}

		initWindow()
	}

	// Edit contextmenu...
	func webView(sender: WebView!, contextMenuItemsForElement element: [NSObject: AnyObject]!, defaultMenuItems: [AnyObject]!) -> [AnyObject]! {
		// @wdg Fix contextmenu (problem with the swift 2 update #50)
		// Issue: #51
		var download = false

		for i in defaultMenuItems {
			// Oh! download link available!
			if (String(i.title).contains("Download")) {
				download = true
			}

			// Get inspect element!
			if (String(i.title).contains("Element")) {
				for x in 0 ..< defaultMenuItems.count {
					if (String(defaultMenuItems[x]).contains("Element")) {
						IElement = defaultMenuItems[x] as! NSMenuItem
					}
				}
			}
		}

		var NewMenu: [AnyObject] = [AnyObject]()
		let contextMenu = SETTINGS["Contextmenu"] as! [String: Bool]

		// if can back
		if (contextMenu["BackAndForward"]!) {
			if (mainWebview.canGoBack) {
				NewMenu.append(NSMenuItem.init(title: "Back", action: #selector(ViewController.goBack(_:)), keyEquivalent: ""))
			}
			if (mainWebview.canGoForward) {
				NewMenu.append(NSMenuItem.init(title: "Forward", action: #selector(ViewController.goForward(_:)), keyEquivalent: ""))
			}
		}
		if (contextMenu["Reload"]!) {
			NewMenu.append(NSMenuItem.init(title: "Reload", action: #selector(ViewController.reloadPage(_:)), keyEquivalent: ""))
		}

		if (download) {
			lastURL = element["WebElementLinkURL"]! as! NSURL

			if (contextMenu["Download"]! || contextMenu["newWindow"]!) {
				NewMenu.append(NSMenuItem.separatorItem())

				if (contextMenu["newWindow"]!) {
					NewMenu.append(NSMenuItem.init(title: "Open Link in a new Window", action: #selector(ViewController.createNewInstance(_:)), keyEquivalent: ""))
				}
				if (contextMenu["Download"]!) {
					NewMenu.append(NSMenuItem.init(title: "Download Linked File", action: #selector(ViewController._doNothing(_:)), keyEquivalent: ""))
				}
			}
		}

		NewMenu.append(NSMenuItem.separatorItem())
		// Add debug menu. (if enabled)
		if (SETTINGS["debugmode"] as! Bool) {
			let debugMenu = NSMenu(title: "Debug")
			debugMenu.addItem(IElement)
			debugMenu.addItem(NSMenuItem.init(title: "Open New window", action: #selector(ViewController._debugNewWindow(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Print arguments", action: #selector(ViewController._debugDumpArguments(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Open URL", action: #selector(ViewController._openURL(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Report an issue on this page", action: #selector(ViewController._reportThisPage(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Print this page", action: #selector(ViewController._printThisPage(_:)), keyEquivalent: "")) // Stupid swift 2.2 does not look in extensions.
			debugMenu.addItem(NSMenuItem.separatorItem())
			debugMenu.addItem(NSMenuItem.init(title: "Fire some random Notifications", action: #selector(ViewController.__sendNotifications(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Reset localstorage", action: #selector(ViewController.resetLocalStorage(_:)), keyEquivalent: ""))

			let item = NSMenuItem.init(title: "Debug", action: #selector(ViewController._doNothing(_:)), keyEquivalent: "")
			item.submenu = debugMenu

			NewMenu.append(item)
			NewMenu.append(NSMenuItem.separatorItem())
		}

		NewMenu.append(NSMenuItem.init(title: "Quit", action: #selector(ViewController._quit(_:)), keyEquivalent: ""))

		return NewMenu
	}

	func _quit(Sender: AnyObject) -> Void {
		exit(0)
	}

	// Debug: doNothing
	func _doNothing(Sender: AnyObject) -> Void {
		// _doNothing
	}

	// Debug: Open new window
	func _debugNewWindow(Sender: AnyObject) -> Void {
		openNewWindow(url: "https://www.google.nl/search?client=safari&rls=en&q=new+window&ie=UTF-8&oe=UTF-8&gws_rd=cr&ei=_8eKVs2WFIbFPd7Sr_gN", height: "0", width: "0")
	}

	// Debug: Print arguments
	func _debugDumpArguments(Sender: AnyObject) -> Void {
		print(Process.arguments)
	}

	// Debug: Send notifications (10)
	func __sendNotifications(Sender: AnyObject) -> Void {
		// Minimize app
		NSApplication.sharedApplication().keyWindow?.miniaturize(self)

		// Fire 10 Notifications
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(05), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(15), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(25), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(35), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(45), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(55), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(65), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(75), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(85), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(95), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
	}

	// Debug: Send notifications (10): Real sending.
	func ___sendNotifications() -> Void {
		// Minimize app
		if (NSApplication.sharedApplication().keyWindow?.miniaturized == false) {
			NSApplication.sharedApplication().keyWindow?.miniaturize(self)
		}

		// Send Actual notification.
		makeNotification("Test Notification", message: "Hi!", icon: "https://camo.githubusercontent.com/ee999b2d8fa5413229fdc69e0b53144f02b7b840/687474703a2f2f376d6e6f79372e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7765627368656c6c2f6c6f676f2e706e673f696d616765566965772f322f772f313238")
	}

	func _openURL(Sender: AnyObject) -> Void {
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

	func _reportThisPage(Sender: AnyObject) -> Void {
		let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.URL?.absoluteString)!
		let host: String = (mainWebview.mainFrame.dataSource?.request.URL?.host)!

		let issue: String = String("Problem loading \(host)").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!.stringByReplacingOccurrencesOfString("&", withString: "%26")
		var body: String = (String("There is a problem loading \(currentUrl)").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())?.stringByReplacingOccurrencesOfString("&", withString: "%26"))!
		body.appendContentsOf("%0D%0AThe%20problem%20is%3A%0D%0A...")

		let url: String = "https://github.com/djyde/WebShell/issues/new?title=\(issue)&body=\(body)"

		NSWorkspace.sharedWorkspace().openURL(NSURL(string: (url as String))!)
	}

	// Stupid swift 2.2 & 3 does not look in extensions.
	// so we'll copy again...
	// @wdg Add Print Support
	// Issue: #39
	func _printThisPage(Sender: AnyObject? = "") -> Void {
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

	func goBack(Sender: AnyObject) -> Void {
		mainWebview.goBack(Sender)
	}

	func goForward(Sender: AnyObject) -> Void {
		mainWebview.goForward(Sender)
	}

	func reloadPage(Sender: AnyObject) -> Void {
		mainWebview.reload(Sender)
	}
    
    // Debug: Open new window
    func createNewInstance(Sender: AnyObject) -> Void {
        openNewWindow(url: "\(lastURL)", height: "0", width: "0")
    }
}
