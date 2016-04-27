//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    let UI_UPDATE_INTERVAL = 1.0 // Seconds
    let IDLE_THRESHOLD = 3.0 // Seconds
    let NOTIFICATION_THRESHOLD = 5.0 // Seconds
    
    var statusBarMenu: StatusBarMenu?
    
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
        
        self.statusBarMenu = StatusBarMenu(statusBar: NSStatusBar.systemStatusBar()).then {
            $0.delegate = self
        }
        
        updateStatus()
        updateIntervalsSum()
    }
    
    private func createTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(UI_UPDATE_INTERVAL,
                                                      target:   self,
                                                      selector: #selector(timerDidFire),
                                                      userInfo: nil,
                                                      repeats:  true)
    }
    
    @objc private func timerDidFire() {
        updateStatus()
        updateIntervalsSum()
    }
    
    private func updateStatus() {
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
        statusBarMenu?.title = title
        
        updateIntervalsSum()
    }
    
    private func updateIntervalsSum() {
        guard statusBarMenu?.isMenuOpen == true else { return }
        guard let formatter = intervalFormatter else { return }
        guard let currentActivityType = activityWatcher?.currentActivityType() else { return }
        guard let lastStateChange = activityWatcher?.lastStateChange else { return }
        
        let currentActivityInterval = NSDate().timeIntervalSinceDate(lastStateChange)
        let activeInterval = activityLog.durationSumForType(.Active) + (currentActivityType == .Active ? currentActivityInterval : 0)
        let idleInterval = activityLog.durationSumForType(.Idle) + (currentActivityType == .Idle ? currentActivityInterval : 0)
        
        statusBarMenu?.activeTime = formatter.stringForInterval(activeInterval)
        statusBarMenu?.idleTime = formatter.stringForInterval(idleInterval)
    }
}

extension AppDelegate: StatusBarMenuDelegate {
    func statusBarMenuDidSelectQuit() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func statusBarMenuWillOpen() {
        updateIntervalsSum()
    }
}

extension SequenceType where Generator.Element == Activity {
    func durationSumForType(type: ActivityType) -> NSTimeInterval {
        return filter { $0.type == type } .reduce(0) { $0 + $1.duration() }
    }
}
