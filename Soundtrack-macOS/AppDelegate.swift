//
//  Copyright (c) 2017 Manav Rathi
//
//  Apache License, v2.0
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var togglePlaybackMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        log.info("Launched: \(notification.userInfo ?? [:])")
    }

    func applicationWillTerminate(_ notification: Notification) {
        log.info("Terminated: \(notification.userInfo ?? [:])")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            sender.windows.first?.makeKeyAndOrderFront(self)
        }
        return true
    }

}

