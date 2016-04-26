//
//  Created by Karol Sarnacki on 26/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import XCTest
@testable import TakeABreak

class ActivityLogEntryTests: XCTestCase {
    
    func testComputesDurationBetweenStartAndFinish() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let logEntry = ActivityLogEntry(type: ActivityType.Active,
                                        start: dateFormatter.dateFromString("2016-04-26 11:26:42")!,
                                        finish: dateFormatter.dateFromString("2016-04-27 09:10:21")!)
        
        XCTAssertEqual(78219, logEntry.duration())
    }
    
}
