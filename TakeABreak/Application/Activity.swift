//
//  ActivityLogEntry.swift
//  TakeABreak
//
//  Created by Karol Sarnacki on 26/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

class Activity {
    let type:   ActivityType
    let start:  Date
    let finish: Date
    
    init(type: ActivityType, start: Date, finish: Date) {
        self.type   = type
        self.start  = start
        self.finish = finish
    }
    
    func duration() -> TimeInterval {
        return finish.timeIntervalSince(start)
        }
    }

