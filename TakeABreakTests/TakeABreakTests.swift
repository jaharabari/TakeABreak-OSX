//
//  Created by Dariusz Rybicki on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import XCTest
@testable import TakeABreak

class TakeABreakTests: XCTestCase {
//    var idleTimes: [Int64]!
    
    func testShouldBeActiveForIdleTimeBelowThreshold() {
        let result = checkActivity(currentIdleSeconds: 59, previousActiveSeconds: 120, secondsSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(result.isActive, true)
        XCTAssertEqual(result.sinceSeconds, 150)
    }
    
    func testShouldBeInactiveForIdleTimeEqualToThreshold() {
        let result = checkActivity(currentIdleSeconds: 60, previousActiveSeconds: 0, secondsSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(result.isActive, false)
        XCTAssertEqual(result.sinceSeconds, 60)
    }
    
    func testShouldBeInactiveForIdleTimeAboveThreshold() {
        let result = checkActivity(currentIdleSeconds: 61, previousActiveSeconds: 0, secondsSinceLastCheck: 30, inactivityThreshold: 60)
        
        XCTAssertEqual(result.isActive, false)
        XCTAssertEqual(result.sinceSeconds, 61)
    }
    
    
    
//    func test() {
//        idleTimes = [
//            0
//        ]
//        
//        var results: [Result] = []
//        var activeSeconds: Int64 = 0
//
//        for idleSeconds in idleTimes {
//            let result = doSomething(currentIdleSeconds: idleSeconds, previousActiveSeconds: activeSeconds, inactivityThreshold: 3 * 60)
//            results.append(result)
//            if result.isActive {
//                activeSeconds = result.sinceSeconds
//            }
//        }
//        
//        let expectation: [Result] = [
//            Result(isActive: false, sinceSeconds: 0)
//        ]
//        
//        XCTAssertEqual(results, expectation)
//    }
//
//    // MARK: - Helpers
//    
//    func assert(idleTimes: [Int64], generateResults: [Result]) {
//        
//    }
}

//typealias Result = (isActive: Bool, sinceSeconds: Int64)

func checkActivity(currentIdleSeconds idle: Int64, previousActiveSeconds active: Int64, secondsSinceLastCheck lastCheck: Int64, inactivityThreshold: Int64) -> Result {
    return Result(isActive: idle < inactivityThreshold, sinceSeconds: active + lastCheck)
}

struct Result {
    let isActive: Bool
    let sinceSeconds: Int64
}

extension Result: Equatable {}

func ==(l: Result, r: Result) -> Bool {
    return l.isActive == r.isActive && l.sinceSeconds == r.sinceSeconds
}
