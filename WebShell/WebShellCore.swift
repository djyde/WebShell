//
//  WebShellCore.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
	// Quit the app (there must be a better way)
	func Quit(sender: AnyObject) {
		exit(0)
	}
	
	// Function to call for the window.open (popup)
	func openNewWindow(url: String, height: String, width: String) -> Void {
		// @wdg Replaced NSPipe for NSWorkspace
		// Issue: #48
		let ws = NSWorkspace.sharedWorkspace()
		do {
			if (self.SETTINGS["debugmode"] as! Bool) {
				try ws.launchApplicationAtURL(NSURL(string: "file://\(Process.arguments[0])")!, options: .NewInstance, configuration: [NSWorkspaceLaunchConfigurationArguments: ["-NSDocumentRevisionsDebugMode", "YES", "-url", url, "-height", height, "-width", width]])
			} else {
				try ws.launchApplicationAtURL(NSURL(string: Process.arguments[0])!, options: .NewInstance, configuration: [NSWorkspaceLaunchConfigurationArguments: ["-url", url, "-height", height, "-width", width]])
			}
		}
		catch {/* we'll never get this. */}
	}
	
	func noop(ob: Any...) -> Void {}
	
	func delay(delay: Double, _ closure: () -> ()) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
	}
}
