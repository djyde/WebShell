# WebShell

![](http://7mnoy7.com1.z0.glb.clouddn.com/github/workflow-with-frame.png?imageView/2/w/1280)

WebShell is an OS X WebView shell, which help you easily bundle the Web Apps to native OS X app without coding.

## Quick Start

```bash

$ git clone git@github.com:djyde/WebShell.git APP_NAME

$ cd APP_NAME && open WebShell.xcodeproj

```

Edit `WebShell/ViewController.swift` and change the url whatever you like:

```swift
let SETTINGS: [String: Any]  = [

  "url": "http://jsbin.com",

  // ... other options
]
```

Finally click the `run` button to run the app.

## Demo

- [JS Bin](https://github.com/djyde/WebShell/releases/download/untagged-26c400bf436fb0f55e9b/JSBin.zip) ([Chinese Mirror](http://7mnoy7.com1.z0.glb.clouddn.com/JSBin.zip))

## Document

For more detail configurations, please see [document](https://github.com/djyde/WebShell/wiki/How-to-build-a-WebShell-based-application)

## Who's using WebShell

If you built any wonderful app with `WebShell`, just let me know!

# License

MIT License