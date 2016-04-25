//
//  ActivityStatus.swift
//  TakeABreak
//
//  Created by Marcin Wieclawski on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

func checkActivity(currentIdleSeconds idle: Int64, previousActiveSeconds active: Int64, secondsSinceLastCheck lastCheck: Int64, inactivityThreshold: Int64) throws -> ActivityStatus {
//    guard idle < lastCheck || active == 0 else { throw CheckError.InvalidIdleTime }
    
    let isActive = idle < inactivityThreshold
    let sinceSeconds = isActive ? active + lastCheck : idle
    return ActivityStatus(isActive: isActive, sinceSeconds: sinceSeconds )
}

struct ActivityStatus {
    let isActive: Bool
    let sinceSeconds: Int64
}

enum CheckError: ErrorType{
    case InvalidIdleTime
}

extension ActivityStatus: Equatable {}

func ==(l: ActivityStatus, r: ActivityStatus) -> Bool {
    return l.isActive == r.isActive && l.sinceSeconds == r.sinceSeconds
}
