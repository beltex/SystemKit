
import IOKit
import Darwin
import CoreFoundation


public class Battery {

    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    private let IOSERVICE_BATTERY = "AppleSmartBattery"
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    public func open() -> kern_return_t {

        // could there be more than one service? serveral batteries?
        var service = IOServiceGetMatchingService(kIOMasterPortDefault,
                 IOServiceNameMatching(IOSERVICE_BATTERY).takeUnretainedValue())
        
        if (service == 0) {
            println("Failed to find service")
        }
        
        //var dict : Unmanaged<CFMutableDictionary>?
        //var result = IORegistryEntryCreateCFProperties(service, &dict, kCFAllocatorDefault, UInt32(kNilOptions))
        //
        //if (result != kIOReturnSuccess) {
        //
        //    println("Create dict error")
        //}
        //
        //var test = dict?.takeUnretainedValue()
        //
        //var test2 = test! as Dictionary
        //
        //println(test2)
        //
        //
        //dict?.release()
        //IOObjectRelease(service)
        
        return kIOReturnSuccess
    }
    
    
    public func isCharging() -> Bool {
        return true
    }
    
    
    public func isCharged() -> Bool {
        return true
    }
    
    
    public func health() -> Double {
        return 0.0
    }
    
    
    public func cycleCount() -> Int {
        return 0
    }
    
    
    public func designCycleCount() -> Int {
        return 0
    }
    
    
    public func TMP() -> Double {
        return 0
    }
    
    
    public func maxCapacity() -> Int {
        return 0
    }
    
    
    public func designCapacity() -> Int {
        return 0
    }
}




