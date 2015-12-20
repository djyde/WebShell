# WebShell

WebShell is an OS X WebView shell, which help you easily bring the Web APPs to native OS X app.

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

- [JS Bin]()

## Document

For more detail configurations, please see [document](https://github.com/djyde/WebShell/wiki/How-to-build-a-WebShell-app)

## Who's using WebShell

If you built any wonderful app with `WebShell`, just let me know!

# License

MIT License