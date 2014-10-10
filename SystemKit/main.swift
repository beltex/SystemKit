
import IOKit
import Darwin
import CoreFoundation


let IOSERVICE_BATTERY = "AppleSmartBattery"

let map = IOServiceNameMatching(IOSERVICE_BATTERY).takeUnretainedValue()

// could there be more than one service? serveral batteries?
var service = IOServiceGetMatchingService(kIOMasterPortDefault, map)

if (service == 0) {
    println("Failed to find service")
}



var dict : Unmanaged<CFMutableDictionary>?
var result = IORegistryEntryCreateCFProperties(service, &dict, kCFAllocatorDefault, UInt32(kNilOptions))

if (result != kIOReturnSuccess) {
    
    println("Create dict error")
}

var test = dict?.takeUnretainedValue()

//var test2 = test! as Dictionary
//
//println(test2)


dict?.release()
IOObjectRelease(service)

