//
//  ActivityLogEntry.swift
//  TakeABreak
//
//  Created by Karol Sarnacki on 26/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

class ActivityLogEntry {
    let type:   ActivityType
    let start:  NSDate
    let finish: NSDate
    
    init(type: ActivityType, start: NSDate, finish: NSDate) {
        self.type   = type
        self.start  = start
        self.finish = finish
    }
    
    func duration() -> NSTimeInterval {
        return finish.timeIntervalSinceDate(start)
    }
}
