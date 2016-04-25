//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import XCTest
@testable import TakeABreak

class TakeABreakTests: XCTestCase {
    
    func testShouldBeActiveForIdleTimeBelowThreshold() {
        let activityStatus = checkActivity(currentIdleSeconds: 59, previousActiveSeconds: 120, secondsSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(activityStatus.isActive, true)
        XCTAssertEqual(activityStatus.sinceSeconds, 150)
    }
    
    func testShouldBeInactiveForIdleTimeEqualToThreshold() {
        let activityStatus = checkActivity(currentIdleSeconds: 60, previousActiveSeconds: 0, secondsSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(activityStatus.isActive, false)
        XCTAssertEqual(activityStatus.sinceSeconds, 60)
    }
    
    func testShouldBeInactiveForIdleTimeAboveThreshold() {
        let activityStatus = checkActivity(currentIdleSeconds: 61, previousActiveSeconds: 0, secondsSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(activityStatus.isActive, false)
        XCTAssertEqual(activityStatus.sinceSeconds, 61)
    }
    
    func testShouldThrowExceptionWhenIdleIsGreaterThanTotalActivitySeconds() {
        checkActivity(currentIdleSeconds: 60, previousActiveSeconds: 20, secondsSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertThrowsError(CheckError.InvalidIdleTime)
    }
}
