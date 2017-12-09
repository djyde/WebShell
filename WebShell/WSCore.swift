//
//  WebShellCore.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import Cocoa

extension WSViewController {
	/**
     Quit the app (there must be a better way)
     */
	func Quit(_ sender: AnyObject) {
		exit(0)
	}

	/**
     Function to call for the window.open (popup)
     
     - Parameter url: The url to open
     - Parameter height: The height for the window
     - Parameter width: The width for the window
     */
	func openNewWindow(url: String, height: String, width: String) -> Void {
		// @wdg Replaced NSPipe for NSWorkspace
		// Issue: #48
		let ws = NSWorkspace.shared
		do {
			if settings.debugmode {
				try ws.launchApplication(at: URL(string: "file://\(CommandLine.arguments[0])")!, options: NSWorkspace.LaunchOptions.newInstance, configuration: [NSWorkspace.LaunchConfigurationKey.arguments: ["-NSDocumentRevisionsDebugMode", "YES", "-url", url, "-height", height, "-width", width]])
			} else {
				try ws.launchApplication(at: URL(string: CommandLine.arguments[0])!, options: NSWorkspace.LaunchOptions.newInstance, configuration: [NSWorkspace.LaunchConfigurationKey.arguments: ["-url", url, "-height", height, "-width", width]])
			}
		}
		catch { /* we'll never get this. */ }
	}

    /**
     Noop a.k.a. No operation.
 
     - Parameter ob: Any ...
     */
	func noop(_ ob: Any ...) -> Void { }

    /**
     Delay a function
     
     - Parameter delay: Time to delay
     - Parameter closure: Code to run (in a escaping block)
     */
	func delay(_ delay: Double, _ closure: @escaping () -> ()) {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
	}
    
    /**
     Run on main thread.
     
     - Parameter run: Code to run (in a escaping block)
     */
    func runOnMain(_ run: @escaping () -> ()) {
        DispatchQueue.main.async(execute: run)
    }
}
