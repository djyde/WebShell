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
    @objc(webView:runOpenPanelForFileButtonWithResultListener:allowMultipleFiles:) func webView(_ sender: WebView!, runOpenPanelForFileButtonWith resultListener: WebOpenPanelResultListener!, allowMultipleFiles: Bool) {
        // Init panel with options
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = allowMultipleFiles
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        
        // On clicked on ok then...
        panel.begin {(result) -> Void in
            // User clicked OK
            if result == NSFileHandlingPanelOKButton {
                
                // make the upload qeue named 'uploadQeue'
                let uploadQeue: NSMutableArray = NSMutableArray()
                for i in 0 ..< panel.urls.count
                {
                    // Add to upload qeue, needing relativePath.
                    uploadQeue.add(panel.urls[i].relativePath)
                }
                
                if (panel.urls.count == 1) {
                    // One file
                    resultListener.chooseFilename(String(describing: uploadQeue[0]))
                } else {
                    // Multiple files
                    resultListener.chooseFilenames(uploadQeue as [AnyObject])
                }
            }
        }
        
    }
    
    func downloadWindow(forAuthenticationSheet download: WebDownload!) -> NSWindow! {
        print("I'd like to download something")
        print(download)
        
        return NSWindow.init()
    }
    
    // Usefull for debugging..
    @nonobjc func webView(_ sender: WebView!,mouseDidMoveOverElement elementInformation: [NSObject : Any]!, modifierFlags: Int) {
        //print("Sender=\(sender)\nEleInfo=\(elementInformation)\nModifier=\(modifierFlags)")
    }
}
