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
    
    let isActive = idle < inactivityThreshold
    let sinceInterval = isActive ? active + lastCheck : idle
    
    return ActivityStatus(isActive: isActive, sinceInterval: sinceInterval)
}

struct ActivityStatus {
    let isActive: Bool
    let sinceInterval: Double
}

enum CheckError: ErrorType {
    case InvalidIdleTime
}

extension ActivityStatus: Equatable {}

func ==(l: ActivityStatus, r: ActivityStatus) -> Bool {
    return l.isActive == r.isActive && l.sinceInterval == r.sinceInterval
}
