//
//  Created by Karol Sarnacki on 26/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

class ActivityWatcher {
    static let DEFAULT_UPDATE_INTERVAL = 0.25 // Seconds
    static let DEFAULT_IDLE_THRESHOLD  = 3.00 // Seconds
    
    private let updateInterval: NSTimeInterval
    private let idleThreshold: NSTimeInterval
    private let onActivityFinished: (Activity -> Void)?
    
    private var timer: NSTimer?
    private var previousActivityType: ActivityType?
    
    var lastStateChange: NSDate?

    init(updateInterval: NSTimeInterval = DEFAULT_UPDATE_INTERVAL,
         idleThreshold: NSTimeInterval = DEFAULT_IDLE_THRESHOLD,
         onActivityFinished: (Activity -> Void)? = nil) {
        self.updateInterval     = updateInterval
        self.idleThreshold      = idleThreshold
        self.onActivityFinished = onActivityFinished
        
        lastStateChange = NSDate()
        timer           = createTimer()
        
        timerDidFire()
    }
    
    func currentActivityType() -> ActivityType {
        return SystemIdleTime()! < idleThreshold ? .Active : .Idle
    }
    
    private func createTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(updateInterval,
                                                      target:   self,
                                                      selector: #selector(timerDidFire),
                                                      userInfo: nil,
                                                      repeats:  true)
    }

    @objc private func timerDidFire() {
        let currentDate  = NSDate()
        let activityType = currentActivityType()
        
        if let previousActivityType = previousActivityType {
            if activityType != previousActivityType {
                let finishDate = currentDate.dateByAddingTimeInterval(activityType == .Idle ? -idleThreshold : 0)
                let activity   = Activity(type: activityType, start: lastStateChange!, finish: finishDate)
                
                onActivityFinished?(activity)
                
                lastStateChange = finishDate
            }
        }
        
        previousActivityType = activityType
    }
    
}