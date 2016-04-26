//
//  Created by Dariusz Rybicki on 26/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

class IntervalFormatter {
    private let formatter: NSDateComponentsFormatter
    
    init() {
        formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
    }
    
    func stringForInterval(interval: Double) -> String {
        // TODO: Add a guard against values larger than Max Int
        
        let components = NSDateComponents()
        components.second = Int(interval) % 60
        components.minute = Int(interval) / 60 % 60
        components.hour = Int(interval) / 3600
        
        return formatter.stringFromDateComponents(components)!
    }
}
