//
//  Notifications.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import AppKit
import AudioToolbox

// @wdg Add Notification Support
// Issue: #2
// This extension will handle the HTML5 Notification API.
extension WSViewController {
	func clearNotificationCount() -> Void {
		notificationCount = 0
	}
	
	// @wdg Add Notification Support
	// Issue: #2
	func makeNotification(_ title: NSString, message: NSString, icon: NSString) -> Void {
		let notification: NSUserNotification = NSUserNotification() // Set up Notification
		
		// If has no message (title = message)
		if (message.isEqual(to: "undefined")) {
			notification.title = Bundle.main.infoDictionary!["CFBundleName"] as? String // Use App name!
			notification.informativeText = title as String // Title   = string
		} else {
			notification.title = title as String // Title   = string
			notification.informativeText = message as String // Message = string
		}
		
		
		notification.soundName = NSUserNotificationDefaultSoundName // Default sound
		notification.deliveryDate = Date(timeIntervalSinceNow: 0) // Now!
		notification.actionButtonTitle = "Close"
		
		// Notification has a icon, so add it!
		if (!icon.isEqual(to: "undefined")) {
			notification.contentImage = NSImage(contentsOf: URL(string: icon as String)!) ;
		}
		
		let notificationcenter: NSUserNotificationCenter? = NSUserNotificationCenter.default // Notification centre
		notificationcenter?.scheduleNotification(notification) // Pushing to notification centre
		
		notificationCount += 1
		
		NSApplication.shared.dockTile.badgeLabel = String(notificationCount)
	}
	
	// @wdg Add Notification Support
	// Issue: #2
	func flashScreen(_ data: NSString) -> Void {
		if ((Int(data as String)) != nil || data.isEqual(to: "undefined")) {
			AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen) ;
		} else {
			let time: [String] = (data as String).components(separatedBy: ",")
			for i in 0 ..< time.count {
                // @wdg Fix flashScreen(...)
                // Issue: #66
                let timeAsNumber = NumberFormatter().number(from: time[i])?.intValue
				Timer.scheduledTimer(timeInterval: TimeInterval(timeAsNumber!), target: self, selector: #selector(WSViewController.flashScreenNow), userInfo: nil, repeats: false)
			}
		}
	}
	
	// @wdg Add Notification Support
	// Issue: #2
	@objc func flashScreenNow() -> Void {
		AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen) ;
	}
}
