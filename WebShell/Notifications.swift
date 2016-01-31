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
extension ViewController {
	func clearNotificationCount() -> Void {
		notificationCount = 0
	}
	
	// @wdg Add Notification Support
	// Issue: #2
	func makeNotification(title: NSString, message: NSString, icon: NSString) -> Void {
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
	func flashScreen(data: NSString) -> Void {
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
	func flashScreenNow() -> Void {
		AudioServicesPlaySystemSound(kSystemSoundID_FlashScreen) ;
	}
}
