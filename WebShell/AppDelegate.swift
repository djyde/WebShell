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

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Add Notification center to the app delegate.
		NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
		mainWindow = NSApplication.sharedApplication().windows[0]
	}

	// @wdg close app if window closes
	// Issue: #40
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		return true
	}

	func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if (!flag) {
			mainWindow!.makeKeyAndOrderFront(self)
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
		mainWindow!.makeKeyAndOrderFront(self)

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
}
