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
    @objc(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:) func webView(_ sender: WebView!, runJavaScriptAlertPanelWithMessage message: String!, initiatedBy frame: WebFrame!) {
        let alert = NSAlert.init()
        alert.addButton(withTitle: "OK")
        alert.messageText = "Message"
        alert.informativeText = message
        alert.runModal()
    }
    
    // webview settings
    @objc(webView:didStartProvisionalLoadForFrame:) func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
        // @wdg: Better progress indicator | Issue: #37
        if ((WebShellSettings["showLoadingBar"] as? Bool)!) {
            progressBar.startAnimation(self)
            progressBar.maxValue = 100;
            progressBar.minValue = 1;
            progressBar.increment(by: 24)
        }
        
        if (!firstLoadingStarted) {
            firstLoadingStarted = true
            launchingLabel.isHidden = false
        }
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    @objc(webView:willPerformClientRedirectToURL:delay:fireDate:forFrame:) func webView(_ sender: WebView!, willPerformClientRedirectTo URL: URL!, delay seconds: TimeInterval, fire date: Date!, for frame: WebFrame!) {
        if ((WebShellSettings["showLoadingBar"] as? Bool)!) {
            progressBar.isHidden = false
            progressBar.startAnimation(self)
            progressBar.maxValue = 100;
            progressBar.minValue = 1;
            progressBar.increment(by: 24)
        }
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    func webView(_ webView: WebView!, decidePolicyForMIMEType type: String!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        if ((WebShellSettings["showLoadingBar"] as? Bool)!) {
            progressBar.isHidden = false
            progressBar.startAnimation(self)
            progressBar.maxValue = 100;
            progressBar.minValue = 1;
            progressBar.increment(by: 24)
        }
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    func webView(_ webView: WebView!, didFailLoadWithError error: NSError) {
        progressBar.increment(by: 50)
        progressBar.stopAnimation(self)
        progressBar.isHidden = true
        progressBar.doubleValue = 1;
    }
    
    // @wdg: Better progress indicator
    // Issue: #37
    @objc(webView:didFinishLoadForFrame:) func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        progressBar.increment(by: 50)
        progressBar.stopAnimation(self)
        progressBar.isHidden = true // Hide after we're done.
        progressBar.doubleValue = 1;
        if (!launchingLabel.isHidden) {
            launchingLabel.isHidden = true
        }
        
        // Inject Webhooks
        self.injectWebhooks(mainWebview.mainFrame.javaScriptContext)
        self.loopThroughiFrames()
        
        // @wdg Add location support
        // Issue: #41
        if (WebShellSettings["needLocation"] as! Bool) {
            self.websiteWantsLocation()
        } else {
            self.locationInjector(false) // Says i don't have a location!
        }
    }
    
    @objc(webView:didReceiveTitle:forFrame:) func webView(_ sender: WebView!, didReceiveTitle title: String!, for frame: WebFrame!) {
        if (WebShellSettings["useDocumentTitle"] as! Bool) {
            mainWindow.window?.title = title
        }
    }
}
