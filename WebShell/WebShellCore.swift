//
//  WebShellCore.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation

extension ViewController {
    // Quit the app (there must be a better way)
    func Quit(sender: AnyObject) {
        exit(0)
    }
    
    // Function to call for the window.open (popup)
    func openNewWindow(url: String, height: String, width: String) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                
                // TODO: This one freezes our main window, even in the qeue
                // TODO: Hide this window
                
                let task = NSTask()
                task.launchPath = Process.arguments[0]
                
                if (self.SETTINGS["debugmode"] as! Bool) {
                    // With debug mode
                    task.arguments = ["-NSDocumentRevisionsDebugMode", "YES", "-url", url, "-height", height, "-width", width]
                } else {
                    // Production mode
                    task.arguments = ["-url", url, "-height", height, "-width", width]
                }
                
                print("Running: \(Process.arguments[0]) -url \"\(url)\" second-argument")
                
                let pipe = NSPipe()
                task.standardOutput = pipe
                task.launch()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                
                let output: String = String(data: data, encoding: NSUTF8StringEncoding)!
                print(output)
            })
        })
    }
    
    func noop(ob: Any...) -> Void {}
    
    func delay(delay: Double, _ closure: () -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
}
