//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var activeTimeMenuItem: NSMenuItem!
    @IBOutlet weak var idleTimeMenuItem: NSMenuItem!
    
    var statusItem: NSStatusItem?
    var timer: NSTimer?
    var dateLastUpdate: NSDate?
    var activeInterval: Double = 0.0
    var notification: NSUserNotification?
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        dateLastUpdate = NSDate()
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)

        statusItem?.title = "Take A Brake"
        statusItem?.menu = statusMenu
        
        let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notificationCenter.delegate = self
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
                if activeInterval > 5 && self.notification == nil {
                    let notification = createNotification()
                    showNotification(notification)
                    self.notification = notification
                }
                statusItem?.title = "Active: \(formatTime(activeInterval))"
            } else {
                activeInterval = 0
                if let notification = self.notification {
                    hideNotification(notification)
                    self.notification = nil
                }
                statusItem?.title = "Idle: \(formatTime(idleInterval))"
            }
        } else {
            statusItem?.title = "Idle: N/A"
        }
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
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
    
    // MARK: - Notifications
    
    private func createNotification() -> NSUserNotification {
        let notification = NSUserNotification()
        notification.title = "Take a Break !!!"
        notification.soundName = NSUserNotificationDefaultSoundName
        
        return notification
    }
    
    private func showNotification(notification: NSUserNotification) {
        let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notificationCenter.deliverNotification(notification)
    }
    
    private func hideNotification(notification: NSUserNotification) {
        let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notificationCenter.removeScheduledNotification(notification)
        notificationCenter.removeDeliveredNotification(notification)
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}
