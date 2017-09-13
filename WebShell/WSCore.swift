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
	func Quit(_ sender: AnyObject) {
		exit(0)
	}

	// Function to call for the window.open (popup)
	func openNewWindow(url: String, height: String, width: String) -> Void {
		// @wdg Replaced NSPipe for NSWorkspace
		// Issue: #48
		let ws = NSWorkspace.shared
		do {
			if (WebShellSettings["debugmode"] as! Bool) {
				try ws.launchApplication(at: URL(string: "file://\(CommandLine.arguments[0])")!, options: NSWorkspace.LaunchOptions.newInstance, configuration: [NSWorkspace.LaunchConfigurationKey.arguments: ["-NSDocumentRevisionsDebugMode", "YES", "-url", url, "-height", height, "-width", width]])
			} else {
				try ws.launchApplication(at: URL(string: CommandLine.arguments[0])!, options: NSWorkspace.LaunchOptions.newInstance, configuration: [NSWorkspace.LaunchConfigurationKey.arguments: ["-url", url, "-height", height, "-width", width]])
			}
		}
		catch { /* we'll never get this. */ }
	}

	func noop(_ ob: Any ...) -> Void { }

	func delay(_ delay: Double, _ closure: @escaping () -> ()) {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
	}
    
    func runOnMain(_ run: @escaping () -> ()) {
        DispatchQueue.main.async(execute: run)
    }
}
