//
//  WebShelllDownloadManager.swift
//  WebShell
//
//  Created by Wesley de Groot on 18-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import AppKit

// @wdg Add Download support
// Issue: #31
// This class will handle WebShell Downloads.
// It's a basic download manager, so no progress, and nothing else, just download.
class WebShelllDownloadManager {
	var TURL: NSURL = NSURL()
	var Fname: String = ""
	var Session: NSURLSession = NSURLSession()
	var DFolder: NSURL = NSURL()

	/**
	 init
	 - Parameter url: URL to download
	 */
	init(url: NSURL) {
		TURL = url
		Fname = url.lastPathComponent!

		DFolder = NSFileManager.defaultManager().URLsForDirectory(.DownloadsDirectory, inDomains: .UserDomainMask).first!

		let downloadsURL = String(DFolder).stringByAppendingString(url.lastPathComponent!)

		self.startDownload(TURL, savePath: NSURL(string: downloadsURL))
	}

	/**
	 Start the download
	 - Parameter URL: The URL to download
	 - Parameter savePath: The savePath
	 */
	func startDownload(URL: NSURL, savePath: NSURL!) {
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = "GET"

		let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
			if (error == nil) {
				let statusCode = (response as! NSHTTPURLResponse).statusCode
				self.noop(statusCode) // For further use HTTP Status code.

				let saveData = NSData.init(data: data!)
				saveData.writeToURL(savePath!, atomically: true)

				// Ask the question on the main queue.
				NSOperationQueue.mainQueue().addOperationWithBlock({
					if (self.dialog("Download of \"\(self.Fname)\" complete", text: "Would you like to open the downloads folder?")) {
						NSWorkspace.sharedWorkspace().openURL(self.DFolder)
					}
				})
			}
			else {
				// Failure
				print("Faulure: %@", error!.localizedDescription);
			}
		})

		task.resume()
	}

	/**
	 Display a nice dialog with a question.\
	 Please remember to use it only on the mainQueue

	 - Parameter question: The question
	 - Parameter text: The text you want to ask
	 - Returns: Bool
	 */
	func dialog(question: String, text: String) -> Bool {
		let myPopup: NSAlert = NSAlert()
		myPopup.messageText = question
		myPopup.informativeText = text
		myPopup.alertStyle = NSAlertStyle.InformationalAlertStyle
		myPopup.addButtonWithTitle("Yes")
		myPopup.addButtonWithTitle("No")

		let res = myPopup.runModal()

		if res == NSAlertFirstButtonReturn {
			return true
		}

		return false
	}

	/**
	 End the download task
	 */
	func endDownloadTask() -> Void { }
    
	/**
	 Noop!
	 */
	func noop(ob: AnyObject) -> Void { }
}