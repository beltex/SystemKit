/*
* System.swift
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

/**
API to read stats from the battery.
*/
public class Battery {

    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Temperature units.
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
    
    
    /**
    I/O Kit Error Codes - as defined in IOReturn.h
    
    Swift can't import complex macros, thus we have to manually add them here.
    Most of these are not relevant to us, but for the sake of completeness.
    
    See "Accessing Hardware From Applications -> Handling Errors" Apple doc for
    more information.
    */
    private enum IOReturn : kern_return_t {
        case kIOReturnSuccess          = 0      // KERN_SUCCESS - OK
        case kIOReturnError            = 0x2bc  // General error
        case kIOReturnNoMemory         = 0x2bd  // Can't allocate memory
        case kIOReturnNoResources      = 0x2be  // Resource shortage
        case kIOReturnIPCError         = 0x2bf  // Error during IPC
        case kIOReturnNoDevice         = 0x2c0  // No such device
        case kIOReturnNotPrivileged    = 0x2c1  // Privilege violation
        case kIOReturnBadArgument      = 0x2c2  // Invalid argument
        case kIOReturnLockedRead       = 0x2c3  // Device read locked
        case kIOReturnExclusiveAccess  = 0x2c5  // Exclusive access and device
                                                // already open
        case kIOReturnBadMessageID     = 0x2c6  // Sent/received messages had
                                                // different msg_id
        case kIOReturnUnsupported      = 0x2c7  // Unsupported function
        case kIOReturnVMError          = 0x2c8  // Misc. VM failure
        case kIOReturnInternalError    = 0x2c9  // Internal error
        case kIOReturnIOError          = 0x2ca  // General I/O error
        case kIOReturnQM1Error         = 0x2cb  // ??? - kIOReturn???Error
        case kIOReturnCannotLock       = 0x2cc  // Can't acquire lock
        case kIOReturnNotOpen          = 0x2cd  // Device not open
        case kIOReturnNotReadable      = 0x2ce  // Read not supported
        case kIOReturnNotWritable      = 0x2cf  // Write not supported
        case kIOReturnNotAligned       = 0x2d0  // Alignment error
        case kIOReturnBadMedia         = 0x2d1  // Media Error
        case kIOReturnStillOpen        = 0x2d2  // Device(s) still open
        case kIOReturnRLDError         = 0x2d3  // RLD failure
        case kIOReturnDMAError         = 0x2d4  // DMA failure
        case kIOReturnBusy             = 0x2d5  // Device Busy
        case kIOReturnTimeout          = 0x2d6  // I/O Timeout
        case kIOReturnOffline          = 0x2d7  // Device offline
        case kIOReturnNotReady         = 0x2d8  // Not ready
        case kIOReturnNotAttached      = 0x2d9  // Device not attached
        case kIOReturnNoChannels       = 0x2da  // No DMA channels left
        case kIOReturnNoSpace          = 0x2db  // No space for data
        case kIOReturnQM2Error         = 0x2dc  // ??? - kIOReturn???Error
        case kIOReturnPortExists       = 0x2dd  // Port already exists
        case kIOReturnCannotWire       = 0x2de  // Can't wire down physical
                                                // memory
        case kIOReturnNoInterrupt      = 0x2df  // No interrupt attached
        case kIOReturnNoFrames         = 0x2e0  // No DMA frames enqueued
        case kIOReturnMessageTooLarge  = 0x2e1  // Oversized msg received on
                                                // interrupt port
        case kIOReturnNotPermitted     = 0x2e2  // Not permitted
        case kIOReturnNoPower          = 0x2e3  // No power to device
        case kIOReturnNoMedia          = 0x2e4  // Media not present
        case kIOReturnUnformattedMedia = 0x2e5  // media not formatted
        case kIOReturnUnsupportedMode  = 0x2e6  // No such mode
        case kIOReturnUnderrun         = 0x2e7  // Data underrun
        case kIOReturnOverrun          = 0x2e8  // Data overrun
        case kIOReturnDeviceError      = 0x2e9  // The device is not working
                                                // properly!
        case kIOReturnNoCompletion     = 0x2ea  // A completion routine is
                                                // required
        case kIOReturnAborted          = 0x2eb  // Operation aborted
        case kIOReturnNoBandwidth      = 0x2ec  // Bus bandwidth would be
                                                // exceeded
        case kIOReturnNotResponding    = 0x2ed  // Device not responding
        case kIOReturnIsoTooOld        = 0x2ee  // Isochronous I/O request for
                                                // distant past!
        case kIOReturnIsoTooNew        = 0x2ef  // Isochronous I/O request for
                                                // distant future
        case kIOReturnNotFound         = 0x2f0  // Data was not found
        case kIOReturnInvalid          = 0x1    // Should never be seen
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
        // TODO: Could there be more than one service? serveral batteries?
        service = IOServiceGetMatchingService(kIOMasterPortDefault,
                 IOServiceNameMatching(IOSERVICE_BATTERY).takeUnretainedValue())
        
        if (service == 0) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) -"
                        + " \(IOSERVICE_BATTERY) service not found")
            #endif
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
      // If AppleSmartBattery is in the I/O reg, then it's a laptop, otherwise
      // not 
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


