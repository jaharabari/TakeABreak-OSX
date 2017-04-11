//
//  Created by Marcin Wieclawski on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

/**
 Returns number of seconds since system became idle
 
 returns: `NSTimeInterval?`: System idle time in seconds or nil when unable to retrieve it
 */
public func SystemIdleTime() -> TimeInterval? {
    var iterator: io_iterator_t = 0
    defer { IOObjectRelease(iterator) }
    guard IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iterator) == KERN_SUCCESS else { return nil }
    
    let entry: io_registry_entry_t = IOIteratorNext(iterator)
    defer { IOObjectRelease(entry) }
    guard entry != 0 else { return nil }
    
    var unmanagedDict: Unmanaged<CFMutableDictionary>? = nil
    defer { unmanagedDict?.release() }
    guard IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS else { return nil }
    guard let dict = unmanagedDict?.takeUnretainedValue() else { return nil }
    
    let key: CFString = "HIDIdleTime" as CFString
    let address = Unmanaged.passUnretained(key).toOpaque()
    let value = CFDictionaryGetValue(dict, address)
    let number: CFNumber = unsafeBitCast(value, to: CFNumber.self)
    var nanoseconds: Int64 = 0
    guard CFNumberGetValue(number, CFNumberType.sInt64Type, &nanoseconds) else { return nil }
    let interval = Double(nanoseconds) / Double(NSEC_PER_SEC)
    
    return interval
}
