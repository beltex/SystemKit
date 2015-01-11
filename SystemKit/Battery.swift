//
// Battery.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import IOKit
import Foundation

/**
Battery statistics for OS X, read-only.

http://www.apple.com/batteries/

TODO: None of this will work for iOS as I/O Kit is a private framework there
*/
public struct Battery {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /// Temperature units
    public enum TemperatureUnit {
        case Celsius
        case Fahrenheit
        case Kelvin
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE ENUMS
    //--------------------------------------------------------------------------
    
    
    /// Battery property names (keys)
    private enum Key: String {
        case ACPowered        = "ExternalConnected"
        case Amperage         = "Amperage"
        /// Current charge
        case CurrentCapacity  = "CurrentCapacity"
        case CycleCount       = "CycleCount"
        /// Originally DesignCapacity == MaxCapacity
        case DesignCapacity   = "DesignCapacity"
        case DesignCycleCount = "DesignCycleCount9C"
        case FullyCharged     = "FullyCharged"
        case IsCharging       = "IsCharging"
        /// Current max charge (this degrades over time)
        case MaxCapacity      = "MaxCapacity"
        case Temperature      = "Temperature"
        /// Time remaining to charge/discharge
        case TimeRemaining    = "TimeRemaining"
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /// Name of the battery IOService as seen in the IORegistry
    private static let IOSERVICE_BATTERY = "AppleSmartBattery"
    
    
    private var service: io_service_t = 0
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() { }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Open a connection to the battery.
    
    :returns: kIOReturnSuccess on success.
    */
    public mutating func open() -> kern_return_t {
        if (service != 0) {
            #if DEBUG
                println("WARNING - \(__FILE__):\(__FUNCTION__) - " +
                        "\(Battery.IOSERVICE_BATTERY) connection already open")
            #endif
            return kIOReturnStillOpen
        }
        
        
        // TODO: Could there be more than one service? serveral batteries?
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
         IOServiceNameMatching(Battery.IOSERVICE_BATTERY).takeUnretainedValue())
        
        if (service == 0) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - " +
                        "\(Battery.IOSERVICE_BATTERY) service not found")
            #endif
            return kIOReturnNotFound
        }
        
        return kIOReturnSuccess
    }
    
    
    /**
    Close the connection to the battery.
    
    :returns: kIOReturnSuccess on success.
    */
    public mutating func close() -> kern_return_t {
        let result = IOObjectRelease(service)
        service    = 0     // Reset this incase open() is called again
        
        #if DEBUG
            if (result != kIOReturnSuccess) {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - Failed to close")
            }
        #endif
        
        return result
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - BATTERY
    //--------------------------------------------------------------------------
    
    
    /**
    Get the current capacity of the battery in mAh. This is essientally the
    current charge of the battery.
    
    https://en.wikipedia.org/wiki/Ampere-hour
    */
    public func currentCapacity() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.CurrentCapacity.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Int
    }
    
    
    /**
    Get the current max capacity of the battery in mAh. This degrades over time
    from the original design capacity.
    
    https://en.wikipedia.org/wiki/Ampere-hour
    */
    public func maxCapactiy() -> Int {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.MaxCapacity.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Int
    }
    
    
    /**
    Get the designed capacity of the battery in mAh. This is a static value.
    The max capacity will be equal to this when new, and as it degrades over
    time, be less than this.
    
    https://en.wikipedia.org/wiki/Ampere-hour
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

    https://en.wikipedia.org/wiki/Charge_cycle
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
    Is the machine powered by AC?
    
    :returns: True if it is, false otherwise.
    */
    public func isACPowered() -> Bool {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.ACPowered.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Bool
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
        return prop.takeUnretainedValue() as Bool
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
        return prop.takeUnretainedValue() as Bool
    }
    
    
    /**
    What is the current charge of the machine?
    */
    public func charge() -> Double {
        return floor(Double(currentCapacity()) / Double(maxCapactiy()) * 100.0)
    }
    
    
    public func timeRemaining() -> Double {
        // TODO: Time format return?
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.TimeRemaining.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        return prop.takeUnretainedValue() as Double
    }

    
    /**
    Get the current temperature of the battery.
    
    :returns: Battery temperature, by default in Celsius.
    */
    public func temperature(unit: TemperatureUnit = .Celsius) -> Double {
        let prop = IORegistryEntryCreateCFProperty(service,
                                                   Key.Temperature.rawValue,
                                                   kCFAllocatorDefault,
                                                   UInt32(kNilOptions))
        
        var temperature = prop.takeUnretainedValue() as Double / 100.0
        
        switch unit {
            case .Celsius:
                // Do nothing - in Celsius by default
                // Must have complete switch though with executed command
                break
            case .Fahrenheit:
                temperature = Battery.toFahrenheit(temperature)
            case .Kelvin:
                temperature = Battery.toKelvin(temperature)
        }
        
        return ceil(temperature)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE HELPERS
    //--------------------------------------------------------------------------
    
    
    /**
    Celsius to Fahrenheit
    
    :param: temperature Temperature in Celsius
    :returns: Temperature in Fahrenheit
    */
    private static func toFahrenheit(temperature: Double) -> Double {
        // https://en.wikipedia.org/wiki/Fahrenheit#Definition_and_conversions
        return (temperature * 1.8) + 32
    }
    
    
    /**
    Celsius to Kelvin
    
    :param: temperature Temperature in Celsius
    :returns: Temperature in Kelvin
    */
    private static func toKelvin(temperature: Double) -> Double {
        // https://en.wikipedia.org/wiki/Kelvin
        return temperature + 273.15
    }
}
