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
            
            if status.isActive {
                activeInterval = status.sinceInterval
                if activeInterval > 5 {
                    notifier?.showNotification(activeInterval: activeInterval)
                }
            } else {
                activeInterval = 0
                notifier?.hideNotification()
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
        if status.isActive {
            statusItem.title = "Active: \(formatter.stringForInterval(status.sinceInterval))"
        } else {
            statusItem.title = "Idle: \(formatter.stringForInterval(status.sinceInterval))"
        }
    }
    
}

class IntervalFormatter {
    private let formatter: NSDateComponentsFormatter
    
    init() {
        formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
    }
    
    func stringForInterval(interval: Double) -> String {
        // TODO: Add a guard against values larger than Max Int
        
        let components = NSDateComponents()
        components.second = Int(interval) % 60
        components.minute = Int(interval) / 60 % 60
        components.hour = Int(interval) / 3600
        
        return formatter.stringFromDateComponents(components)!
    }
}

class ActivityNotifier: NSObject, NSUserNotificationCenterDelegate {
    private let notificationCenter: NSUserNotificationCenter
    private let formatter: IntervalFormatter
    private var notification: NSUserNotification?
    
    init(notificationCenter: NSUserNotificationCenter, formatter: IntervalFormatter) {
        self.notificationCenter = notificationCenter
        self.formatter = formatter
        super.init()
        self.notificationCenter.delegate = self
    }
    
    func showNotification(activeInterval activeInterval: Double) {
        let notification = createNotification()
        notification.soundName = self.notification == nil ? NSUserNotificationDefaultSoundName : nil
        notification.informativeText = "You are active for \(formatter.stringForInterval(activeInterval))"
        
        self.notification = notification
        notificationCenter.deliverNotification(notification)
    }
    
    func hideNotification() {
        guard let notification = self.notification else { return }
        notificationCenter.removeScheduledNotification(notification)
        notificationCenter.removeDeliveredNotification(notification)
        self.notification = nil
    }
    
    private func createNotification() -> NSUserNotification {
        let notification = NSUserNotification()
        notification.identifier = NSUUID().UUIDString
        notification.title = "Take a Break !!!"
        
        return notification
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}
