//
// System.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014, 2015  beltex <https://github.com/beltex>
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

import Darwin
import Foundation

//------------------------------------------------------------------------------
// MARK: PRIVATE PROPERTIES
//------------------------------------------------------------------------------


// As defined in <mach/tash_info.h>

private let HOST_BASIC_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(sizeof(host_basic_info_data_t) / sizeof(integer_t))
private let HOST_LOAD_INFO_COUNT          : mach_msg_type_number_t =
                       UInt32(sizeof(host_load_info_data_t) / sizeof(integer_t))
private let HOST_CPU_LOAD_INFO_COUNT      : mach_msg_type_number_t =
                   UInt32(sizeof(host_cpu_load_info_data_t) / sizeof(integer_t))
private let HOST_VM_INFO64_COUNT          : mach_msg_type_number_t =
                      UInt32(sizeof(vm_statistics64_data_t) / sizeof(integer_t))
private let HOST_SCHED_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(sizeof(host_sched_info_data_t) / sizeof(integer_t))
private let PROCESSOR_SET_LOAD_INFO_COUNT : mach_msg_type_number_t =
              UInt32(sizeof(processor_set_load_info_data_t) / sizeof(natural_t))


public struct System {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /**
    System page size.
    
    - Can check this via pagesize shell command as well
    - C lib function getpagesize()
    - host_page_size()
    
    TODO: This should be static right?
    */
    public static let PAGE_SIZE = vm_kernel_page_size
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Unit options for method data returns.
    
    TODO: Pages?
    */
    public enum Unit : Double {
        // For going from byte to -
        case Byte     = 1
        case Kilobyte = 1024
        case Megabyte = 1048576
        case Gigabyte = 1073741824
    }
    
    
    /// Options for loadAverage()
    public enum LOAD_AVG {
        /// 5, 30, 60 second samples
        case SHORT
        
        /// 1, 5, 15 minute samples
        case LONG
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    

    private static let machHost = mach_host_self()
    private var loadPrevious = host_cpu_load_info(cpu_ticks: (0,0,0,0))
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() { }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Get CPU usage (system, user, idle, nice). Determined by the delta between
    the current and last call. Thus, first call will always be inaccurate.
    */
    public mutating func usageCPU() -> (system : Double,
                                        user   : Double,
                                        idle   : Double,
                                        nice   : Double) {
        let load = System.hostCPULoadInfo()
        
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sysDiff  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        
        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff
        
        let sys  = sysDiff  / totalTicks * 100.0
        let user = userDiff / totalTicks * 100.0
        let idle = idleDiff / totalTicks * 100.0
        let nice = niceDiff / totalTicks * 100.0
        
        loadPrevious = load
        
        // TODO: 2 decimal places
        // TODO: Check that total is 100%
        return (sys, user, idle, nice)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC STATIC METHODS
    //--------------------------------------------------------------------------
    
    
    /// Get the model name of this machine. Same as "sysctl hw.model"
    public static func modelName() -> String {
        var name = String()
        var mib  = [CTL_HW, HW_MODEL]

        // Max model name size not defined by sysctl. Instead we use io_name_t
        // via I/O Kit which can also get the model name
        var size = size_t(sizeof(io_name_t))

        var ptr    = UnsafeMutablePointer<io_name_t>.alloc(1)
        let result = sysctl(&mib, u_int(mib.count), ptr, &size, nil, 0)

        if result == 0 { name = String.fromCString(UnsafePointer(ptr))! }

        ptr.dealloc(1)

        #if DEBUG
            if result != 0 {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - errno = "
                        + "\(result)")
            }
        #endif

        return name
    }


    /**
    sysname       Name of the operating system implementation.
    nodename      Network name of this machine.
    release       Release level of the operating system.
    version       Version level of the operating system.
    machine       Machine hardware platform.

    Via uname(3) manual page.
    */
    public static func uname() -> (sysname: String, nodename: String,
                                                     release: String,
                                                     version: String,
                                                     machine: String) {
        // Takes a generic pointer type because the type were dealing with
        // (from the utsname struct) is a huge tuple of Int8s (once bridged to
        // Swift), so it would be really messy to go that route (would have to
        // type it all out explicitly)
        func toString<T>(ptr: UnsafePointer<T>) -> String {
            return String.fromCString(UnsafePointer<CChar>(ptr))!
        }

        var tuple  = ("", "", "", "", "")
        var names  = UnsafeMutablePointer<utsname>.alloc(1)
        let result = Foundation.uname(names)

        #if DEBUG
            if result != 0 {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - errno = "
                        + "\(result)")
            }
        #endif

        if result == 0 {
            let sysname  = withUnsafePointer(&names.memory.sysname,  toString)
            let nodename = withUnsafePointer(&names.memory.nodename, toString)
            let release  = withUnsafePointer(&names.memory.release,  toString)
            let version  = withUnsafePointer(&names.memory.version,  toString)
            let machine  = withUnsafePointer(&names.memory.machine,  toString)

            tuple = (sysname, nodename, release, version, machine)
        }

        names.dealloc(1)

        return tuple
    }


    /// Number of physical cores on this machine.
    public static func physicalCores() -> Int {
        return Int(System.hostBasicInfo().physical_cpu)
    }
    
    
    /**
    Number of logical cores on this machine. Will be equal to physicalCores()
    unless it has hyper-threading, in which case it will be double.
    
    https://en.wikipedia.org/wiki/Hyper-threading
    */
    public static func logicalCores() -> Int {
        return Int(System.hostBasicInfo().logical_cpu)
    }
    
    
    /**
    System load average at 3 intervals.
    
    "Measures the average number of threads in the run queue."
    
    - via hostinfo manual page
    
    https://en.wikipedia.org/wiki/Load_(computing)
    */
    public static func loadAverage(type: LOAD_AVG = .LONG) -> [Double] {
        var avg = [Double](count: 3, repeatedValue: 0)
        
        switch type {
            case .SHORT:
                let result = System.hostLoadInfo().avenrun
                avg = [Double(result.0) / Double(LOAD_SCALE),
                       Double(result.1) / Double(LOAD_SCALE),
                       Double(result.2) / Double(LOAD_SCALE)]
            case .LONG:
                getloadavg(&avg, 3)
        }
        
        return avg
    }
    
    
    /**
    System mach factor at 3 intervals.
    
    "A variant of the load average which measures the processing resources
    available to a new thread. Mach factor is based on the number of CPUs
    divided by (1 + the number of runnablethreads) or the number of CPUs minus
    the number of runnable threads when the number of runnable threads is less
    than the number of CPUs. The closer the Mach factor value is to zero, the
    higher the load. On an idle system with a fixed number of active processors,
    the mach factor will be equal to the number of CPUs."
    
    - via hostinfo manual page
    */
    public static func machFactor() -> [Double] {
        let result = System.hostLoadInfo().mach_factor
        
        return [Double(result.0) / Double(LOAD_SCALE),
                Double(result.1) / Double(LOAD_SCALE),
                Double(result.2) / Double(LOAD_SCALE)]
    }
    
    
    /// Total number of processes
    public static func processCount() -> Int {
        return Int(System.processorLoadInfo().task_count)
    }
    
    
    /// Total number of threads
    public static func threadCount() -> Int {
        return Int(System.processorLoadInfo().thread_count)
    }
    
    
    /// Size of physical memory on this machine
    public static func physicalMemory(unit: Unit = .Gigabyte) -> Double {
        return Double(System.hostBasicInfo().max_mem) / unit.rawValue
    }
    
    
    /**
    System memory usage (free, active, inactive, wired, compressed).
    */
    public static func memoryUsage() -> (free       : Double,
                                         active     : Double,
                                         inactive   : Double,
                                         wired      : Double,
                                         compressed : Double) {
        let stats = System.VMStatistics64()
        
        let free     = Double(stats.free_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        let active   = Double(stats.active_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        let inactive = Double(stats.inactive_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        let wired    = Double(stats.wire_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        
        // Result of the compression. This is what you see in Activity Monitor
        let compressed = Double(stats.compressor_page_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        
        return (free, active, inactive, wired, compressed)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    
    private static func hostBasicInfo() -> host_basic_info {
        // TODO: Why is host_basic_info.max_mem val different from sysctl?
        
        var size     = HOST_BASIC_INFO_COUNT
        var hostInfo = host_basic_info_t.alloc(1)
        
        let result = host_info(machHost, HOST_BASIC_INFO,
                                         UnsafeMutablePointer(hostInfo),
                                         &size)
        
        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif
        
        return data
    }

    
    private static func hostLoadInfo() -> host_load_info {
        var size     = HOST_LOAD_INFO_COUNT
        var hostInfo = host_load_info_t.alloc(1)
        
        let result = host_statistics(machHost, HOST_LOAD_INFO,
                                               UnsafeMutablePointer(hostInfo),
                                               &size)
        
        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif
        
        return data
    }
    
    
    private static func hostCPULoadInfo() -> host_cpu_load_info {
        var size     = HOST_CPU_LOAD_INFO_COUNT
        var hostInfo = host_cpu_load_info_t.alloc(1)
        
        let result = host_statistics(machHost, HOST_CPU_LOAD_INFO,
                                               UnsafeMutablePointer(hostInfo),
                                               &size)
        
        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif

        return data
    }
    
    
    private static func processorLoadInfo() -> processor_set_load_info {
        // NOTE: Duplicate load average and mach factor here
        
        // TODO: Move processor_set_default() call to init()
        var pset: processor_set_name_t = 0
        var result = processor_set_default(machHost, &pset)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            #endif
            return processor_set_load_info(task_count   : 0,
                                           thread_count : 0,
                                           load_average : 0,
                                           mach_factor  : 0)
        }

        
        var count = PROCESSOR_SET_LOAD_INFO_COUNT
        var info_out = processor_set_load_info_t.alloc(1)
        
        result = processor_set_statistics(pset,
                                          PROCESSOR_SET_LOAD_INFO,
                                          UnsafeMutablePointer(info_out),
                                          &count)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            #endif
        }
        
        
        let data = info_out.move()
        info_out.dealloc(1)
        
        return data
    }
    
    
    /**
    64-bit virtual memory statistics. This should apply to all Mac's that run
    10.9 and above. For iOS, iPhone 5S, iPad Air & iPad Mini 2 and on.
    
    Swift runs on 10.9 and above, and 10.9 is x86_64 only. On iOS though its 7
    and above, with both ARM & ARM64.
    */
    private static func VMStatistics64() -> vm_statistics64 {
        var size     = HOST_VM_INFO64_COUNT
        var hostInfo = vm_statistics64_t.alloc(1)
        
        let result = host_statistics64(machHost,
                                       HOST_VM_INFO64,
                                       UnsafeMutablePointer(hostInfo),
                                       &size)

        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                    + "\(result)")
            }
        #endif
        
        return data
    }
}
