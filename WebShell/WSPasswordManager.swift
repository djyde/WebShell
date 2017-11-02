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
        let listener = """
var WSPasswordManager = {
  currentSite: document.location.host,

  initialize: function (username, password) {
    WSPasswordManager.checkForms()
alert('INIT')
  },

  checkForms: function () {
    var pst = document.getElementsByTagName('form')
    for (var ii = 0, jj = pst.length; ii < jj; ii++) {
      if (pst[ii].method.toLowerCase() === 'post') {
alert('HOOKED')
        pst[ii].setAttribute('onsubmit', 'event.preventDefault();return WSPasswordManager.validate(this);')
      }
    }
  },

  validate: function (form) {
alert('VALIDATING')
    var username = form.querySelectorAll("input[name='username']")
    var password = form.querySelectorAll("input[name='password']")

    if (username.length > 0 && password.length > 0) {
      if (typeof WSApp !== 'undefined') {
        WSApp.savePassword(username[0].value, password[0].value)
      } else {
        window.alert('Internal error\nPassword manager failed to initialize')
      }
    }

    return false
  }
}

document.addEventListener('DOMContentLoaded', function () {
  WSPasswordManager.initialize()
}, false)
"""
        if (WebShell().Settings["passwordManager"] as! Bool) {
            Dprint("Injecting password manager")
            jsContext.evaluateScript(listener)
        } else {
            Dprint("NOT Injecting password manager")
        }
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
        print("Saving password for \(website)")
        let database = UserDefaults.init(suiteName: website)
        database?.set(website, forKey: "website")
        database?.set(username, forKey: "username")
        database?.set(password, forKey: "password")
        database?.synchronize()
    }
}
