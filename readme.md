# WebShell

WebShell is an OS X WebView shell, which help you easily bring the Web APPs to native OS X app.

## Usage

```bash

$ git clone git@github.com:djyde/WebShell.git APP_NAME

$ cd APP_NAME && open WebShell.xcodeproj

```

## Configure

Only a few steps:

##### STEP1:

`WebShell/ViewController.swift`:

```swift
// TODO: configure your app here
let SETTINGS: [String: Any]  = [
    
    "url": "https://jsfiddle.net", // the webapp url which will be load in webview
    "title": "WebShell", // app window title
    
    // Note that the window  min height is 640 and min width is 1000 by default. You could change it in Main.storyboard
    "height": 640,
    "width": 1000,

    "showLoadingBar": true
]
```

##### STEP2:

WIP...

# License

MIT License