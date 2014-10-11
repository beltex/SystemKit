
import IOKit
import Darwin
import Foundation
import CoreFoundation


var battery = Battery()
assert(battery.open() == kIOReturnSuccess)

println("Cycle Count: \(battery.cycleCount())")

battery.close()


//let IOSERVICE_BATTERY = "AppleSmartBattery"
//
//let map = IOServiceNameMatching(IOSERVICE_BATTERY).takeUnretainedValue()
//
//// could there be more than one service? serveral batteries?
//var service = IOServiceGetMatchingService(kIOMasterPortDefault, map)
//
//if (service == 0) {
//    println("Failed to find service")
//}
//
//
//
//var dict : Unmanaged<CFMutableDictionary>?
//var result = IORegistryEntryCreateCFProperties(service, &dict, kCFAllocatorDefault, UInt32(kNilOptions))
//
//if (result != kIOReturnSuccess) {
//    
//    println("Create dict error")
//}

//var str : NSString = "Hello"
//var key : CFString = "CycleCount"
//var prop = IORegistryEntryCreateCFProperty(service, key, kCFAllocatorDefault, UInt32(kNilOptions))
//
//var val = prop.takeUnretainedValue() as Int
//println(val)
//
//var test = dict?.takeUnretainedValue()


//var notePort = IONotificationPortCreate(kIOMasterPortDefault)

//IONotificationPortSetDispatchQueue(<#notify: IONotificationPort!#>, <#queue: dispatch_queue_t!#>)

//var test2 = test! as Dictionary
//
//println(test)


//dict?.release()
//IOObjectRelease(service)

