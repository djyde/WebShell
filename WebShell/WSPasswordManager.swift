//
//  WSPasswordManager.swift
//  WebShell
//
//  Created by Wesley de Groot on 02-11-17.
//  Copyright © 2017 RandyLu. All rights reserved.
//

//TODO: Create a safe password sorage.

import Foundation
import WebKit

extension ViewController {
    /**
     Inject the password for a website (*via self.injectWebhooks*)
     
     @wdg memorize credentials (*Issue: #74*)
     
     - Parameter jsContext: JSContext!
     - Parameter website: String (site host)
     */
    internal func _injectPasswordFor(_ jsContext: JSContext!, website: String) -> Void {
        let database = UserDefaults.init(suiteName: website)
        if let savedUsername = database?.object(forKey: "username") {
            if let savedPassword = database?.object(forKey: "password") {
                let loadUsernameJS = "var inputFields = document.querySelectorAll(\"input[name='username']\"); \\ for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = \'\(savedUsername)\';}"
                let loadPasswordJS = "var inputFields = document.querySelectorAll(\"input[name='password']\"); \\ for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = \'\(savedPassword)\';}"
                
                jsContext.evaluateScript(loadUsernameJS)
                jsContext.evaluateScript(loadPasswordJS)
            }
        }
        
        database?.synchronize()
    }
    
    /**
     Inject the password grabber for a website
     
     @wdg memorize credentials (*Issue: #74*)
     
     - Parameter jsContext: JSContext!
     - Parameter website: String (site host)
     */
    internal func _injectPasswordListener(_ jsContext: JSContext!, website: String) -> Void {
        let database = UserDefaults.init(suiteName: website)
        
        database?.synchronize()
    }
    
    /**
     Save a password to the database (*via self.injectWebhooks*)
     
     @wdg memorize credentials (*Issue: #74*)
     
     - Parameter jsContext: JSContext!
     - Parameter website: String (site host)
     - Parameter username: String
     - Parameter password: String
     */
    internal func _savePasswordFor(_ jsContext: JSContext!, website: String, username: String, password: String) -> Void {
        let database = UserDefaults.init(suiteName: website)
        database?.set(website, forKey: "website")
        database?.set(username, forKey: "username")
        database?.set(password, forKey: "password")
        database?.synchronize()
    }
}
