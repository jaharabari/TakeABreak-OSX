//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    var statusItem: NSStatusItem?
    var timer: NSTimer?
    var dateLastUpdate: NSDate?
    var activeInterval: Double = 0.0
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        dateLastUpdate = NSDate()
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)

        statusItem?.title = "Take A Brake"
        statusItem?.menu = statusMenu
    }
    
    func timerDidFire() {
        let currentDate = NSDate()
        let delta = currentDate.timeIntervalSinceDate(dateLastUpdate!)
        
        dateLastUpdate = currentDate
        
        if let idleInterval = SystemIdleTime() {
            let status = try! checkActivity(currentIdleInterval: idleInterval,
                                            previousActiveInterval: activeInterval,
                                            intervalSinceLastCheck: delta,
                                            inactivityThreshold: 3)
            
            if status.isActive {
                activeInterval = status.sinceInterval
                statusItem?.title = "Active: \(formatTime(activeInterval))"
            } else {
                activeInterval = 0
                statusItem?.title = "Idle: \(formatTime(idleInterval))"
            }
        } else {
            statusItem?.title = "Idle: N/A"
        }
    }
    
    @IBAction func menuClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    private func formatTime(interval: Double) -> String {
        // TODO: Add a guard against values larger than Max Int
        
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        
        let components = NSDateComponents()
        components.second = Int(interval) % 60
        components.minute = Int(interval) / 60 % 60
        components.hour = Int(interval) / 3600
        
        return formatter.stringFromDateComponents(components)!
    }
    
}
