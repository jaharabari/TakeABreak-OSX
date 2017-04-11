//
//  Created by Karol Sarnacki on 26/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

class ActivityWatcher {
    static let DEFAULT_UPDATE_INTERVAL = 0.25 // Seconds
    static let DEFAULT_IDLE_THRESHOLD  = 3.00 // Seconds
    
    fileprivate let updateInterval: TimeInterval
    fileprivate let idleThreshold: TimeInterval
    fileprivate let onActivityFinished: ((Activity) -> Void)?
    
    fileprivate var timer: Timer?
    fileprivate var previousActivityType: ActivityType?
    
    var activityData = [String]()
    
    var lastStateChange: Date?

    init(updateInterval: TimeInterval = DEFAULT_UPDATE_INTERVAL,
         idleThreshold: TimeInterval = DEFAULT_IDLE_THRESHOLD,
         onActivityFinished: ((Activity) -> Void)? = nil) {
        self.updateInterval     = updateInterval
        self.idleThreshold      = idleThreshold
        self.onActivityFinished = onActivityFinished
        
        lastStateChange = Date()
        timer           = createTimer()
        
        timerDidFire()
        
    }
    
    func currentActivityType() -> ActivityType {
        return SystemIdleTime()! < idleThreshold ? .Active : .Idle
    }
    
    func createTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: updateInterval,
                                                      target:   self,
                                                      selector: #selector(timerDidFire),
                                                      userInfo: nil,
                                                      repeats:  true)
    }

    @objc fileprivate func timerDidFire() {
        let currentDate  = Date()
        let activityType = currentActivityType()
        
        defer { self.previousActivityType = activityType }
        
        guard let previousActivityType = previousActivityType, activityType != previousActivityType else { return }

        let finishDate = currentDate.addingTimeInterval(activityType == .Idle ? -idleThreshold : 0)
        let finishedActivity = Activity(type: previousActivityType, start: lastStateChange!, finish: finishDate)
            
        onActivityFinished?(finishedActivity)
        lastStateChange = finishDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        let stringFinishDate = dateFormatter.string(from: finishDate)
        
        activityData.append((activityType.rawValue) + " at " + (stringFinishDate))
        
        
        
    }
    
}
