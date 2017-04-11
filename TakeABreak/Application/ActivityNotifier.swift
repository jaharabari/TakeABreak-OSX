//
//  Created by Dariusz Rybicki on 26/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

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
    
    func showNotification(activeInterval: Double) {
        let notification = createNotification()
        notification.soundName = self.notification == nil ? NSUserNotificationDefaultSoundName : nil
        notification.informativeText = "You are active for \(formatter.stringForInterval(activeInterval))"
        
        self.notification = notification
        notificationCenter.deliver(notification)
    }
    
    func hideNotification() {
        guard let notification = self.notification else { return }
        notificationCenter.removeScheduledNotification(notification)
        notificationCenter.removeDeliveredNotification(notification)
        self.notification = nil
    }
    
    private func createNotification() -> NSUserNotification {
        let notification = NSUserNotification()
        notification.identifier = UUID().uuidString
        notification.title = "Take a Break !!!"
        
        return notification
    }
    
    // MARK: - NSUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
