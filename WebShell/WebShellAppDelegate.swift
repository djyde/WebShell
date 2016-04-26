//
//  AppDelegate.swift
//  WebShell
//
//  Created by Randy on 15/12/19.
//  Copyright © 2015 RandyLu. All rights reserved.
//
//  Wesley de Groot (@wdg), Added Notification and console.log Support

import Cocoa
import Foundation
import NotificationCenter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

	var mainWindow: NSWindow!
	let popover = NSPopover()
	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
	var eventMonitor: EventMonitor?

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// @wdg Merge Statut with WebShell.
		// Issue: #56
		if (WebShell().Settings["MenuBarApp"] as! Bool) {
			if let button = statusItem.button {
				button.image = NSImage(named: "AppIcon") // StatusBarButtonImage
				button.action = #selector(AppDelegate.togglePopover(_:))
			}

			popover.contentViewController = WebShellPopupViewController(nibName: "WebShellPopupViewController", bundle: nil)

			initialPopupSize()

			eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) { [unowned self] event in
				if self.popover.shown {
					self.closePopover(event)
				}
			}
			eventMonitor?.start()
		} else {
			// Add Notification center to the app delegate.
			NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
			mainWindow = NSApplication.sharedApplication().windows[0]
		}
	}

	// @wdg close app if window closes
	// Issue: #40
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		if (!(WebShell().Settings["MenuBarApp"] as! Bool)) {
			return true
		} else {
			return false
		}
	}

	func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if (!flag) {
			if (!(WebShell().Settings["MenuBarApp"] as! Bool)) {
				mainWindow!.makeKeyAndOrderFront(self)
			}
		}

		// clear badge
		NSApplication.sharedApplication().dockTile.badgeLabel = ""
		// @wdg Clear notification count
		// Issue: #34
		NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications()
		return true
	}

	// @wdg Add Notification Support
	// Issue: #2
	func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
		// We (i) want Notifications support
		return true
	}

	// @wdg Add 'click' on notification support
	// Issue: #26
	func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
		// Open window if user clicked on notification!
		if (!(WebShell().Settings["MenuBarApp"] as! Bool)) {
			mainWindow!.makeKeyAndOrderFront(self)
		}

		// @wdg Clear badge
		NSApplication.sharedApplication().dockTile.badgeLabel = ""
		// @wdg Clear notification count
		// Issue: #34
		NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications()
	}

	@IBAction func printThisPage(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName("printThisPage", object: nil)
	}

	@IBAction func goHome(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName("goHome", object: nil)
	}

	@IBAction func reload(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName("reload", object: nil)
	}

	@IBAction func copyUrl(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName("copyUrl", object: nil)
	}

	// Statut merge...
	func initialPopupSize() {
		popover.contentSize.width = CGFloat(WebShell().Settings["initialWindowWidth"] as! Int)
		popover.contentSize.height = CGFloat(WebShell().Settings["initialWindowHeight"] as! Int)
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	func showPopover(sender: AnyObject?) {
		if let button = statusItem.button {
			popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
		}
		eventMonitor?.start()
	}

	func closePopover(sender: AnyObject?) {
		popover.performClose(sender)
		eventMonitor?.stop()
	}

	func togglePopover(sender: AnyObject?) {
		if (popover.shown) {
			closePopover(sender)
		} else {
			showPopover(sender)
		}
	}
}
