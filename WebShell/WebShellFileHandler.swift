//
//  WebShellFileHandler.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit

// @wdg: Enable file uploads.
// Issue: #29
// This extension will handle up & downloads
extension ViewController {
    
    // @wdg: Enable file uploads.
    // Issue: #29
    func webView(sender: WebView!, runOpenPanelForFileButtonWithResultListener resultListener: WebOpenPanelResultListener!, allowMultipleFiles: Bool) {
        // Init panel with options
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = allowMultipleFiles
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        
        // On clicked on ok then...
        panel.beginWithCompletionHandler {(result) -> Void in
            // User clicked OK
            if result == NSFileHandlingPanelOKButton {
                
                // make the upload qeue named 'uploadQeue'
                let uploadQeue: NSMutableArray = NSMutableArray()
                for i in 0 ..< panel.URLs.count
                {
                    // Add to upload qeue, needing relativePath.
                    uploadQeue.addObject(panel.URLs[i].relativePath!)
                }
                
                if (panel.URLs.count == 1) {
                    // One file
                    resultListener.chooseFilename(String(uploadQeue[0]))
                } else {
                    // Multiple files
                    resultListener.chooseFilenames(uploadQeue as [AnyObject])
                }
            }
        }
        
    }
    
}
