//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import XCTest
@testable import TakeABreak

class TakeABreakTests: XCTestCase {
    
    func testShouldBeActiveForIdleTimeBelowThreshold() {
        let activityStatus = try? checkActivity(currentIdleInterval: 59, previousActiveInterval: 120, intervalSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(activityStatus?.type, .Active)
        XCTAssertEqual(activityStatus?.sinceInterval, 150)
    }
    
    func testShouldBeInactiveForIdleTimeEqualToThreshold() {
        let activityStatus = try? checkActivity(currentIdleInterval: 60, previousActiveInterval: 0, intervalSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(activityStatus?.type, .Idle)
        XCTAssertEqual(activityStatus?.sinceInterval, 60)
    }
    
    func testShouldBeInactiveForIdleTimeAboveThreshold() {
        let activityStatus = try? checkActivity(currentIdleInterval: 61, previousActiveInterval: 0, intervalSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(activityStatus?.type, .Idle)
        XCTAssertEqual(activityStatus?.sinceInterval, 61)
    }
    
    func testShouldThrowExceptionWhenIdleIsGreaterThanTotalActivityInterval() {
        // XCTAssertThrowsError(try checkActivity(currentIdleInterval: 60, previousActiveInterval: 20, intervalSinceLastCheck: 30, inactivityThreshold: 60))
    }
}
