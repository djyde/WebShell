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
	let statusItem = NSStatusBar.system.statusItem(withLength: -2)
	var eventMonitor: EventMonitor?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// @wdg Merge Statut with WebShell.
		// Issue: #56
		if Settings.shared.menuBarApp {
			if let button = statusItem.button {
				button.image = NSImage(named: NSImage.Name(rawValue: "MenuIcon")) // StatusBarButtonImage
				button.action = #selector(AppDelegate.togglePopover(_:))
			}
			
			let sb = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main") , bundle: nil)
			popover.contentViewController = sb.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WSView")) as? NSViewController

			initialPopupSize()

			eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [unowned self] event in
				if self.popover.isShown {
					self.closePopover(event)
				}
			}
			eventMonitor?.start()
		} else {
			// Add Notification center to the app delegate.
			NSUserNotificationCenter.default.delegate = self
			mainWindow = NSApplication.shared.windows[0]
		}
		// Change menus
		let title = Settings.shared.title
		let app = NSApplication.shared
		let mainMenu = app.mainMenu
		if let items = mainMenu?.items {
			// App menu
			let itm0 = items[0]
			itm0.title = title
			// About
			let itm1 = itm0.submenu!.items[0]
			itm1.title = "About " + title
			// Hide
			let itm2 = itm0.submenu!.items[2]
			itm2.title = "Hide " + title
			// Quit
			let itm3 = itm0.submenu!.items[8]
			itm3.title = "Quit " + title
		}
	}

	// @wdg close app if window closes
	// Issue: #40
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		if !Settings.shared.menuBarApp {
			return true
		} else {
			return false
		}
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if !flag {
			if !Settings.shared.menuBarApp {
				mainWindow!.makeKeyAndOrderFront(self)
			}
		}

		// clear badge
		NSApplication.shared.dockTile.badgeLabel = ""
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
		if !Settings.shared.menuBarApp {
			mainWindow!.makeKeyAndOrderFront(self)
		}

		// @wdg Clear badge
		NSApplication.shared.dockTile.badgeLabel = ""
		// @wdg Clear notification count
		// Issue: #34
		NSUserNotificationCenter.default.removeAllDeliveredNotifications()
	}

    /**
     Print the current page
     
     - Parameter sender: the sender object
     */
	@IBAction func printThisPage(_ sender: AnyObject) -> Void {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "printThisPage"), object: nil)
	}

    /**
     Go to the given homepage as set in `Settings.swift`
     
     - Parameter sender: the sender object
     */
	@IBAction func goHome(_ sender: AnyObject) -> Void {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "goHome"), object: nil)
	}

    /**
     Reload the current page
     
     - Parameter sender: the sender object
     */
	@IBAction func reload(_ sender: AnyObject) -> Void {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
	}

    /**
     Copy the url of the current page
     
     - Parameter sender: the sender object
     */
	@IBAction func copyUrl(_ sender: AnyObject) -> Void {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "copyUrl"), object: nil)
	}

    /**
     Popover initial popup size
    */
	func initialPopupSize() -> Void {
		popover.contentSize.width = CGFloat(Settings.shared.initialWindowWidth)
		popover.contentSize.height = CGFloat(Settings.shared.initialWindowHeight)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

    /**
     Show the popover screen
     
     - Parameter sender: the sender object
     */
	func showPopover(_ sender: AnyObject?) {
		if let button = statusItem.button {
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
		}
		eventMonitor?.start()
	}

    /**
     Close the popover screen
     
     - Parameter sender: the sender object
     */
	func closePopover(_ sender: AnyObject?) {
		popover.performClose(sender)
		eventMonitor?.stop()
	}

    /**
     Toggle the popover screen
     
     - Parameter sender: the sender object
     */
	@objc func togglePopover(_ sender: AnyObject?) {
		if (popover.isShown) {
			closePopover(sender)
		} else {
			showPopover(sender)
		}
	}
}
