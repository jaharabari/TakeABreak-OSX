//
//  File.swift
//  TakeABreak
//
//  Created by Marcin Wieclawski on 25/04/16.
//  Copyright © 2016 EL Passion. All rights reserved.
//

import Foundation

/**
 Returns number of seconds since system became idle
 
 returns: `Int64?`: System idle time in seconds or nil when unable to retrieve it
 */
public func SystemIdleTime() -> Int64? {
    var iterator: io_iterator_t = 0
    defer { IOObjectRelease(iterator) }
    guard IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iterator) == KERN_SUCCESS else { return nil }
    
    let entry: io_registry_entry_t = IOIteratorNext(iterator)
    defer { IOObjectRelease(entry) }
    guard entry != 0 else { return nil }
    
    var unmanagedDict: Unmanaged<CFMutableDictionaryRef>? = nil
    defer { unmanagedDict?.release() }
    guard IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS else { return nil }
    guard let dict = unmanagedDict?.takeUnretainedValue() else { return nil }
    
    let value = CFDictionaryGetValue(dict, unsafeAddressOf("HIDIdleTime"))
    let number: CFNumberRef = unsafeBitCast(value, CFNumberRef.self)
    var nanoseconds: Int64 = 0
    guard CFNumberGetValue(number, CFNumberType.SInt64Type, &nanoseconds) else { return nil }
    let seconds = nanoseconds >> 30
    
    return seconds
}