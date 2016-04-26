//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var activeTimeMenuItem: NSMenuItem!
    @IBOutlet weak var idleTimeMenuItem: NSMenuItem!
    
    var statusItem: NSStatusItem?
    var timer: NSTimer?
    var dateLastUpdate: NSDate?
    var activeInterval: Double = 0.0
    var previousActivityType: ActivityType?
    
    var notifier: ActivityNotifier?
    var intervalFormatter: IntervalFormatter?
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        let intervalFormatter = IntervalFormatter()
        self.intervalFormatter = intervalFormatter
        
        notifier = ActivityNotifier(
            notificationCenter: NSUserNotificationCenter.defaultUserNotificationCenter(),
            formatter: intervalFormatter
        )
        
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
            
            switch status.type {
            case .Active:
                activeInterval = status.sinceInterval
                if activeInterval > 5 {
                    notifier?.showNotification(activeInterval: activeInterval)
                }
                
                break
            case .Idle:
                activeInterval = 0
                notifier?.hideNotification()
                
                break
            }
            
            if let statusItem = statusItem {
                updateStatusItem(statusItem, forStatus: status)
            }
        }
        else {
            statusItem?.title = "N/A"
        }
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    private func updateStatusItem(statusItem: NSStatusItem, forStatus status: ActivityStatus) {
        guard let formatter = intervalFormatter else {
            statusItem.title = "N/A"
            return
        }
        
        switch status.type {
        case .Active:
            statusItem.title = "Active: \(formatter.stringForInterval(status.sinceInterval))"
            
            break
        case .Idle:
            statusItem.title = "Idle: \(formatter.stringForInterval(status.sinceInterval))"
            
            break
        }
    }
}
