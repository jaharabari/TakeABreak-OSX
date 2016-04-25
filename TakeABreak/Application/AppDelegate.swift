//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var timer: NSTimer?
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)

        statusItem.title = "Take-A-Brake"
        statusItem.menu = statusMenu
    }
    
    func timerDidFire() {
        statusItem.title = "Idle: \(SystemIdleTime())"
    }
    
    @IBAction func menuClicked(sender: NSMenuItem) {
     NSApplication.sharedApplication().terminate(self)
    }
}
