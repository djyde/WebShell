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
	let statusItem = NSStatusBar.system().statusItem(withLength: -2)
	var eventMonitor: EventMonitor?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// @wdg Merge Statut with WebShell.
		// Issue: #56
		if (WebShell().Settings["MenuBarApp"] as! Bool) {
			if let button = statusItem.button {
				button.image = NSImage(named: "AppIcon") // StatusBarButtonImage
				button.action = #selector(AppDelegate.togglePopover(_:))
			}

			popover.contentViewController = WebShellPopupViewController(nibName: "WebShellPopupViewController", bundle: nil)

			initialPopupSize()

			eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
				if self.popover.isShown {
					self.closePopover(event)
				}
			}
			eventMonitor?.start()
		} else {
			// Add Notification center to the app delegate.
			NSUserNotificationCenter.default.delegate = self
			mainWindow = NSApplication.shared().windows[0]
		}
	}

	// @wdg close app if window closes
	// Issue: #40
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		if (!(WebShell().Settings["MenuBarApp"] as! Bool)) {
			return true
		} else {
			return false
		}
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if (!flag) {
			if (!(WebShell().Settings["MenuBarApp"] as! Bool)) {
				mainWindow!.makeKeyAndOrderFront(self)
			}
		}

		// clear badge
		NSApplication.shared().dockTile.badgeLabel = ""
		// @wdg Clear notification count
		// Issue: #34
		NSUserNotificationCenter.default.removeAllDeliveredNotifications()
		return true
	}

	// @wdg Add Notification Support
	// Issue: #2
	func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
		// We (i) want Notifications support
		return true
	}

	// @wdg Add 'click' on notification support
	// Issue: #26
	func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
		// Open window if user clicked on notification!
		if (!(WebShell().Settings["MenuBarApp"] as! Bool)) {
			mainWindow!.makeKeyAndOrderFront(self)
		}

		// @wdg Clear badge
		NSApplication.shared().dockTile.badgeLabel = ""
		// @wdg Clear notification count
		// Issue: #34
		NSUserNotificationCenter.default.removeAllDeliveredNotifications()
	}

	@IBAction func printThisPage(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "printThisPage"), object: nil)
	}

	@IBAction func goHome(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "goHome"), object: nil)
	}

	@IBAction func reload(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
	}

	@IBAction func copyUrl(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "copyUrl"), object: nil)
	}

	// Statut merge...
	func initialPopupSize() {
		popover.contentSize.width = CGFloat(WebShell().Settings["initialWindowWidth"] as! Int)
		popover.contentSize.height = CGFloat(WebShell().Settings["initialWindowHeight"] as! Int)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func showPopover(_ sender: AnyObject?) {
		if let button = statusItem.button {
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
		}
		eventMonitor?.start()
	}

	func closePopover(_ sender: AnyObject?) {
		popover.performClose(sender)
		eventMonitor?.stop()
	}

	func togglePopover(_ sender: AnyObject?) {
		if (popover.isShown) {
			closePopover(sender)
		} else {
			showPopover(sender)
		}
	}
}
