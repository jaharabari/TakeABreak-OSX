//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    let UI_UPDATE_INTERVAL = 1.0 // Seconds
    let IDLE_THRESHOLD = 3.0 // Seconds
    let NOTIFICATION_THRESHOLD = 5.0 // Seconds
    
    
    var activityWatcher: ActivityWatcher?
    var notifier: ActivityNotifier?
    var intervalFormatter: IntervalFormatter?
    var timer: NSTimer?
    var activityLog = [Activity]()
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        activityWatcher = ActivityWatcher(idleThreshold: IDLE_THRESHOLD,
                                          onActivityFinished: { [weak self] in
                                            self?.activityLog.append($0)
                                          })
        timer = createTimer()
        
        let intervalFormatter = IntervalFormatter()
        self.intervalFormatter = intervalFormatter
        
        notifier = ActivityNotifier(
            notificationCenter: NSUserNotificationCenter.defaultUserNotificationCenter(),
            formatter: intervalFormatter
        )
        
        
        updateStatus()
    }
    
    private func createTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(UI_UPDATE_INTERVAL,
                                                      target:   self,
                                                      selector: #selector(updateStatus),
                                                      userInfo: nil,
                                                      repeats:  true)
    }
    
    @objc private func updateStatus() {
        guard let lastStateChange = activityWatcher?.lastStateChange else { return }
        
        let interval     = NSDate().timeIntervalSinceDate(lastStateChange)
        let activityType = activityWatcher!.currentActivityType()
        
        switch activityType {
        case .Active where interval > NOTIFICATION_THRESHOLD:
            notifier?.showNotification(activeInterval: interval)
        case .Active: break
        case .Idle:
            notifier?.hideNotification()
        }
        
        guard let formatter = intervalFormatter else { return }
        
        var title = activityType == .Active ? "Active: " : "Idle: "
        title += formatter.stringForInterval(interval)
    }
}
