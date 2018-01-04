//
//  WebShelllDownloadManager.swift
//  WebShell
//
//  Created by Wesley de Groot on 18-04-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import AppKit


/**
 @wdg Add Download support
 
 Issue: #31
 
 This class will handle WebShell Downloads.
 
 It's a basic download manager, so no progress, and nothing else, just download.
 */
class WebShelllDownloadManager {
	var TURL: URL
	var Fname: String = ""
	var Session: URLSession = URLSession()
	var DFolder: URL

	/**
	 init
	 - Parameter url: URL to download
	 */
	init(url: URL) {
		TURL = url
		Fname = url.lastPathComponent

		DFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        let downloadsURL = String(describing: DFolder) + url.lastPathComponent

		self.startDownload(TURL, savePath: URL(string: downloadsURL))
	}

	/**
	 Start the download
	 - Parameter URL: The URL to download
	 - Parameter savePath: The savePath
	 */
	func startDownload(_ URL: Foundation.URL, savePath: Foundation.URL!) {
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
		let request = NSMutableURLRequest(url: URL)
		request.httpMethod = "GET"

        noop(session) // temporary we want no stupid "fix-it" warnings.
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
			if (error == nil) {
				let statusCode = (response as! HTTPURLResponse).statusCode
				self.noop(statusCode as AnyObject) // For further use HTTP Status code.

				let saveData = NSData.init(data: data!) as Data
				try? saveData.write(to: savePath!, options: [.atomic])

				// Ask the question on the main queue.
				OperationQueue.main.addOperation({
					if (self.dialog("Download of \"\(self.Fname)\" complete", text: "Would you like to open the downloads folder?")) {
						NSWorkspace.shared.open(self.DFolder)
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
	func dialog(_ question: String, text: String) -> Bool {
		let myPopup: NSAlert = NSAlert()
		myPopup.messageText = question
		myPopup.informativeText = text
		myPopup.alertStyle = NSAlert.Style.informational
		myPopup.addButton(withTitle: "Yes")
		myPopup.addButton(withTitle: "No")

		let res = myPopup.runModal()

		if res == NSApplication.ModalResponse.alertFirstButtonReturn {
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
	func noop(_ ob: AnyObject) -> Void { }
}
