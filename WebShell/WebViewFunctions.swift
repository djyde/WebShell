//
//  WebViewFunctions.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit

// See: #43
extension ViewController {
    func webView(sender: WebView!, runJavaScriptAlertPanelWithMessage message: String!, initiatedByFrame frame: WebFrame!) {
        let alert = NSAlert.init()
        alert.addButtonWithTitle("OK")
        alert.messageText = "Message"
        alert.informativeText = message
        alert.runModal()
    }
    
    // webview settings
    func webView(sender: WebView!, didStartProvisionalLoadForFrame frame: WebFrame!) {
        // @wdg: Better progress indicator | Issue: #37
        if ((SETTINGS["showLoadingBar"] as? Bool)!) {
            progressBar.startAnimation(self)
            progressBar.maxValue = 100;
            progressBar.minValue = 1;
            progressBar.incrementBy(24)
        }
        
        if (!firstLoadingStarted) {
            firstLoadingStarted = true
            launchingLabel.hidden = false
        }
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    func webView(sender: WebView!, willPerformClientRedirectToURL URL: NSURL!, delay seconds: NSTimeInterval, fireDate date: NSDate!, forFrame frame: WebFrame!) {
        if ((SETTINGS["showLoadingBar"] as? Bool)!) {
            progressBar.hidden = false
            progressBar.startAnimation(self)
            progressBar.maxValue = 100;
            progressBar.minValue = 1;
            progressBar.incrementBy(24)
        }
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    func webView(webView: WebView!, decidePolicyForMIMEType type: String!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        if ((SETTINGS["showLoadingBar"] as? Bool)!) {
            progressBar.hidden = false
            progressBar.startAnimation(self)
            progressBar.maxValue = 100;
            progressBar.minValue = 1;
            progressBar.incrementBy(24)
        }
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    func webView(webView: WebView!, didFailLoadWithError error: NSError) {
        progressBar.incrementBy(50)
        progressBar.stopAnimation(self)
        progressBar.hidden = true
        progressBar.doubleValue = 1;
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        progressBar.incrementBy(50)
        progressBar.stopAnimation(self)
        progressBar.hidden = true // Hide after we're done.
        progressBar.doubleValue = 1;
        if (!launchingLabel.hidden) {
            launchingLabel.hidden = true
        }
        
        // Inject Webhooks
        self.injectWebhooks(mainWebview.mainFrame.javaScriptContext)
        self.loopThroughiFrames()
        
        // @wdg Add location support
        // Issue: #41
        if (SETTINGS["needLocation"] as! Bool) {
            self.websiteWantsLocation()
        } else {
            self.locationInjector(false) // Says i don't have a location!
        }
    }
    
    func webView(sender: WebView!, didReceiveTitle title: String!, forFrame frame: WebFrame!) {
        if (SETTINGS["useDocumentTitle"] as! Bool) {
            mainWindow.window?.title = title
        }
    }
}