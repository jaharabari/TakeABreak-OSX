//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    func applicationDidFinishLaunching(notification: NSNotification) {
       
    
        statusItem.title = "Take-A-Brake"
        statusItem.menu = statusMenu
    }
    
    @IBAction func menuClicked(sender: NSMenuItem) {
     NSApplication.sharedApplication().terminate(self)
    }
}
