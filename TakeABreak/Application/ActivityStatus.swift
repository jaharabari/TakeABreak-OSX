//
//  ActivityStatus.swift
//  TakeABreak
//
//  Created by Marcin Wieclawski on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

func checkActivity(currentIdleInterval idle: Double, previousActiveInterval active: Double, intervalSinceLastCheck lastCheck: Double, inactivityThreshold: Double) throws -> ActivityStatus {
    // guard idle < lastCheck || active == 0 else { throw CheckError.InvalidIdleTime }
    
    let type : ActivityType = idle < inactivityThreshold ? .Active : .Idle
    let sinceInterval = type == .Active ? active + lastCheck : idle
    
    return ActivityStatus(type: type, sinceInterval: sinceInterval)
}

struct ActivityStatus {
    let type: ActivityType
    let sinceInterval: Double
}

enum CheckError: ErrorType {
    case InvalidIdleTime
}

extension ActivityStatus: Equatable {}

func ==(l: ActivityStatus, r: ActivityStatus) -> Bool {
    return l.type == r.type && l.sinceInterval == r.sinceInterval
}
