/*
* Battery.swift
* SystemKit
*
* The MIT License (MIT)
*
* Copyright (C) 2014  beltex <https://github.com/beltex>
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import IOKit
import Foundation

//------------------------------------------------------------------------------
// MARK: GLOBAL PRIVATE PROPERTIES
//------------------------------------------------------------------------------


/**
Name of the battery IOService as seen in the IORegistry. You can view it either
via command line with ioreg or through the IORegistryExplorer app (found on
Apple's developer site - Hardware IO Tools for Xcode)
*/
private let IOSERVICE_BATTERY = "AppleSmartBattery"


/**
API to read stats from the battery. Only applicable to laptops (MacBooks).
*/
public class Battery {

    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Temperature units.
    */
    public enum TemperatureUnit {
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
    
    
    private var service: io_service_t = 0
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Open a connection to the battery. If this method fails, it may be because
    the machine is not a laptop. See isLaptop().
    
    :returns: kIOReturnSuccess on successful connection to the battery.
    */
    public func open() -> kern_return_t {
        // TODO: Could there be more than one service? serveral batteries?
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                 IOServiceNameMatching(IOSERVICE_BATTERY).takeUnretainedValue())
        
        if (service == 0) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) -"
                        + " \(IOSERVICE_BATTERY) service not found")
            #endif
            return kIOReturnNotFound
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
    public class func isLaptop() -> Bool {
      // If the AppleSmartBattery is in the I/O Registry, then it's a laptop
      let exist = IOServiceNameMatching(IOSERVICE_BATTERY).takeUnretainedValue()

      return exist == 0 ? false : true
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
    public func tmp(unit: TemperatureUnit = .Celsius) -> Double {
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
    
    
    /**
    Celsius to Fahrenheit
    */
    private class func toFahrenheit(tmp : Double) -> Double {
        // https://en.wikipedia.org/wiki/Fahrenheit#Definition_and_conversions
        return (tmp * 1.8) + 32
    }
    
    
    /**
    Celsius to Kelvin
    */
    private class func toKelvin(tmp : Double) -> Double {
        // https://en.wikipedia.org/wiki/Kelvin
        return tmp + 273.15
    }
}
