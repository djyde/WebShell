//
//  WebshellViewDid.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import Darwin

// See: #43
extension ViewController {
    override func viewDidAppear() {
        if (firstAppear) {
            initWindow()
        }
    }
    
    // @wdg Possible fix for Mavericks
    // Issue: #18
    override func awakeFromNib() {
        if (!NSViewController().respondsToSelector(Selector("viewWillAppear"))) {
            // OS X 10.9
            if (firstAppear) {
                initWindow()
            }

            mainWebview.UIDelegate = self
            mainWebview.resourceLoadDelegate = self
            
            checkSettings()
            addObservers()
            initSettings()
            goHome()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainWebview.UIDelegate = self
        mainWebview.resourceLoadDelegate = self

        checkSettings()
        addObservers()
        initSettings()
        goHome()
    }

}