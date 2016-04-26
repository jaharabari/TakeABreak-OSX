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
    
    let THRESHOLD = 3.0 // Seconds
    let NOTIFICATION_THRESHOLD = 5.0 // Seconds
    
    var statusItem: NSStatusItem?
    var timer: NSTimer?
    var activityLog: [Activity]?
    
    var lastStateActive: Bool?
    var lastStateChange: NSDate?
    
    var notifier: ActivityNotifier?
    var intervalFormatter: IntervalFormatter?
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        let intervalFormatter = IntervalFormatter()
        self.intervalFormatter = intervalFormatter
        
        notifier = ActivityNotifier(
            notificationCenter: NSUserNotificationCenter.defaultUserNotificationCenter(),
            formatter: intervalFormatter
        )
        
        activityLog = [Activity]()
        lastStateChange = NSDate()
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)

        statusItem?.title = "Take A Brake"
        statusItem?.menu = statusMenu
    }
    
    func isActive(idleTime: NSTimeInterval, threshold: NSTimeInterval) -> Bool {
        return idleTime <= threshold
    }

    func timerDidFire() {
        let idleTime = SystemIdleTime()!
        let active = isActive(idleTime, threshold: THRESHOLD)
        let currentDate = NSDate()
        
        if let lastStateActive = lastStateActive {
            if lastStateActive != active {
                let finishDate = currentDate.dateByAddingTimeInterval(active ? 0 : -THRESHOLD)
                let activity = Activity(type: active ? .Active : .Idle,
                                        start: lastStateChange!,
                                        finish: finishDate)
                activityLog?.append(activity)
                
                print("\(activity)")
                
                lastStateChange = finishDate
            }
        }
        
        lastStateActive = active
        
        if let lastStateChange = lastStateChange {
            let interval = NSDate().timeIntervalSinceDate(lastStateChange)
            if active {
                if interval > NOTIFICATION_THRESHOLD {
                    notifier?.showNotification(activeInterval: interval)
                }
            }
            else {
                notifier?.hideNotification()
            }
            if let formatter = intervalFormatter {
                var title = active ? "Active: " : "Inactive: "
                title += formatter.stringForInterval(interval)
                statusItem?.title = title
            }
        }
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
