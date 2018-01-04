//
//  WSPasswordManager.swift
//  WebShell
//
//  Created by Wesley de Groot on 02-11-17.
//  Copyright © 2017 Wesley de Groot. All rights reserved.
//
//  TODO: Create a safe password storage, instead of UserDefaults.

import Foundation
import WebKit

extension WSViewController {
    /**
     Inject the password manager for a website (*via self.injectWebhooks*)
     
     @wdg memorize credentials (*Issue: #74*)
     
     - Parameter jsContext: JSContext!
     - Parameter website: String (site host)
     */
    internal func _injectPasswordFor(_ jsContext: JSContext!, website: String) -> Void {
        let database = UserDefaults(suiteName: website)
        if let savedUsername = database?.object(forKey: "username") {
            if let savedPassword = database?.object(forKey: "password") {
                let loadUsernameJS = "var inputFields = document.querySelectorAll(\"input[name='username']\"); for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = \'\(savedUsername)\';}"
                let loadPasswordJS = "var inputFields = document.querySelectorAll(\"input[name='password']\"); for (var i = inputFields.length >>> 0; i--;) { inputFields[i].value = \'\(savedPassword)\';}"
                
                jsContext.evaluateScript(loadUsernameJS)
                jsContext.evaluateScript(loadPasswordJS)
            }
        }
        
        database?.synchronize()
    }
    
    /**
     Inject the password manager for a website (*grabber part*)
     
     @wdg memorize credentials (*Issue: #74*)
     
     - Parameter jsContext: JSContext!
     - Parameter website: String (site host)
     */
    internal func _injectPasswordListener(_ jsContext: JSContext!, website: String) -> Void {
        let database = UserDefaults(suiteName: website)
        let listener = "var WSPasswordManager={currentSite:document.location.host,initialize:function(e,a){WSPasswordManager.checkForms()},checkForms:function(){for(var e=document.getElementsByTagName(\"form\"),a=0,t=e.length;t>a;a++)\"post\"===e[a].method.toLowerCase()&&e[a].setAttribute(\"onsubmit\",\"event.preventDefault();return WSPasswordManager.validate(this);\")},validate:function(e){var a=e.querySelectorAll(\"input[name='username']\"),t=e.querySelectorAll(\"input[name='password']\");return a.length>0&&t.length>0&&(\"undefined\"!=typeof WSApp?WSApp.savePassword(a[0].value,t[0].value):window.alert(\"Internal error\nPassword manager failed to initialize\")),!1}};WSPasswordManager.initialize();"
        if settings.passwordManager {
            jsContext.evaluateScript(listener)
        }
        database?.synchronize()
    }
    
    /**
     Save a password to the database (*via _injectPasswordListener*)
     
     @wdg memorize credentials (*Issue: #74*)
     
     - Parameter jsContext: JSContext!
     - Parameter website: String (site host)
     - Parameter username: String
     - Parameter password: String
     */
    internal func _savePasswordFor(_ jsContext: JSContext!, website: String, username: String, password: String) -> Void {
        let database = UserDefaults(suiteName: website)
        database?.set(website, forKey: "website")
        database?.set(username, forKey: "username")
        database?.set(password, forKey: "password")
        database?.synchronize()
    }
}
