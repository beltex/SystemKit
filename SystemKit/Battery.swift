
import IOKit
import Foundation

/**
API to read stats from the battery.
*/
public class Battery {

    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Temperature units.
    
    TODO: Move this to a global place, as CPU will propbably need this as well.
    */
    public enum TMP_Unit {
        case Celsius
        case Fahrenheit
        case Kelvin
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Battery property names (keys).
    */
    private enum Key : String {
        case CurrentCapacity  = "CurrentCapacity"
        case CycleCount       = "CycleCount"
        case DesignCapacity   = "DesignCapacity"
        case DesignCycleCount = "DesignCycleCount9C"
        case FullyCharged     = "FullyCharged"
        case IsCharging       = "IsCharging"
        case Temperature      = "Temperature"
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    private let IOSERVICE_BATTERY = "AppleSmartBattery"
    
    
    private var service : io_service_t = 0
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Open a connection to the battery.
    
    :returns: kIOReturnSuccess on successful connection to the battery.
    */
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
    
    
    /**
    Close the connection to the battery.
    
    :returns: kIOReturnSuccess on successful close of the connection to the
              battery.
    */
    public func close() -> kern_return_t {
        return IOObjectRelease(service)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - BATTERY
    //--------------------------------------------------------------------------
    
    /**
    Get the current capacity of the battery.
    
    TODO: Units
    
    :returns:
    */
    public func currentCapacity() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.CurrentCapacity.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Int
    }
    
    
    /**
    Get the designed capacity of the battery.
    
    TODO: Units
    
    :returns:
    */
    public func designCapacity() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.DesignCapacity.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Int
    }
    
    
    /**
    Get the current cycle count of the battery.
    
    :returns:
    */
    public func cycleCount() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.CycleCount.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Int
    }
    
    
    /**
    Get the desgined cycle count of the battery.
    
    :returns:
    */
    public func designCycleCount() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                  Key.DesignCycleCount.rawValue,
                                                  kCFAllocatorDefault,
                                                  UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Int
    }
    
    
    
    /**
    Is the battery charging?
    
    :returns: True if it is, false otherwise.
    */
    public func isCharging() -> Bool {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.IsCharging.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        
        return prop.takeUnretainedValue() as Int == 1 ? true : false
    }
    
    
    /**
    Is the battery fully charged?
    
    :returns: True if it is, false otherwise.
    */
    public func isCharged() -> Bool {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.FullyCharged.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        
        return prop.takeUnretainedValue() as Int == 1 ? true : false
    }
    
    
    /**
    Is this machine a laptop? By that we simply mean, does it have a battery?
    
    :returns: True if it is, false otherwise.
    */
    public func isLaptop() -> Bool {
      // TODO: Implement
      return true
    }
    
    
    /**
    What is the current health of the battery? This is a measure of how much the
    batteries capacity has dimished from the original. Thus, health =
    
        current capacity / design capacity
    
    :returns:
    */
    public func health() -> Double {
        // TODO: Decimal places
        return ceil((Double(currentCapacity()) / Double(designCapacity()))
                     * 100.0)
    }
    
    

    /**
    Get the current temperature of the battery.
    */
    public func tmp(unit : TMP_Unit = .Celsius) -> Double {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.Temperature.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        
        var tmp = prop.takeUnretainedValue() as Double / 100.0
        
        switch unit {
            case .Celsius:
                // Do nothing - in Celsius by default
                // Must have complete switch though with executed command
                tmp = tmp + 0.0
            case .Fahrenheit:
                tmp = Battery.toFahrenheit(tmp)
            case .Kelvin:
                tmp = Battery.toKelvin(tmp)
        }
        
        return tmp
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS - HELPERS
    //--------------------------------------------------------------------------
    
    
    // TODO: Move these to a global place, as CPU will propbably need them too
    
    
    /**
    Celsius to Fahrenheit
    */
    private class func toFahrenheit(tmp : Double) -> Double {
        // http://en.wikipedia.org/wiki/Fahrenheit#Definition_and_conversions
        return (tmp * 1.8) + 32
    }
    
    
    /**
    Celsius to Kelvin
    */
    private class func toKelvin(tmp : Double) -> Double {
        // http://en.wikipedia.org/wiki/Kelvin
        return tmp + 273.15
    }
}


