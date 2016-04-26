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
    
    var statusItem: NSStatusItem?
    var timer: NSTimer?
    var dateLastUpdate: NSDate?
    var activeInterval: Double = 0.0
    var previousActivityStatus: ActivityStatus?
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
        dateLastUpdate = NSDate()
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
        

//        let delta = currentDate.timeIntervalSinceDate(dateLastUpdate!)
//        
//        if let idleInterval = SystemIdleTime() {
//            let status = try! checkActivity(currentIdleInterval: idleInterval,
//                                            previousActiveInterval: activeInterval,
//                                            intervalSinceLastCheck: delta,
//                                            inactivityThreshold: 3)
//            
//            switch status.type {
//            case .Active:
//                activeInterval = status.sinceInterval
//                if activeInterval > 5 {
//                    notifier?.showNotification(activeInterval: activeInterval)
//                }
//            case .Idle:
//                activeInterval = 0
//                notifier?.hideNotification()
//            }
//            
//            if let statusItem = statusItem {
//                updateStatusItem(statusItem, forStatus: status)
//            }
//        }
//        else {
//            statusItem?.title = "N/A"
//        }
        
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
        case .Idle:
            statusItem.title = "Idle: \(formatter.stringForInterval(status.sinceInterval))"
        }
    }
}
