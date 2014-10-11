
import IOKit
import Darwin
import CoreFoundation


public class Battery {

    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    private let IOSERVICE_BATTERY = "AppleSmartBattery"
    
    
    private var service : io_service_t = 0
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    public func open() -> kern_return_t {
        // Could there be more than one service? serveral batteries?
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                 IOServiceNameMatching(IOSERVICE_BATTERY).takeUnretainedValue())
        
        if (service == 0) {
            println("ERROR: Could not find \(IOSERVICE_BATTERY)")
            return IOReturn.kIOReturnNotFound.rawValue
        }
        
        return kIOReturnSuccess
    }
    
    
    public func close() -> kern_return_t {
        return IOObjectRelease(service)
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
        let key : CFString = "CycleCount"
        var prop = IORegistryEntryCreateCFProperty(service,
                                                   key,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Int
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


