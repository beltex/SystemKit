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
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Darwin
import Foundation

//------------------------------------------------------------------------------
// MARK: GLOBAL PUBLIC PROPERTIES
//------------------------------------------------------------------------------


// As defined in <mach/machine.h>

public let CPU_TYPE_X86       : cpu_type_t = 7
public let CPU_TYPE_I386      : cpu_type_t = CPU_TYPE_X86
public let CPU_TYPE_X86_64    : cpu_type_t = CPU_TYPE_X86 | CPU_ARCH_ABI64
public let CPU_TYPE_ARM       : cpu_type_t = 12
public let CPU_TYPE_ARM64     : cpu_type_t = CPU_TYPE_ARM | CPU_ARCH_ABI64
public let CPU_TYPE_POWERPC   : cpu_type_t = 18
public let CPU_TYPE_POWERPC64 : cpu_type_t = CPU_TYPE_POWERPC | CPU_ARCH_ABI64


/**
System page size.

- Can check this via pagesize shell command as well
- C lib function getpagesize()
- host_page_size()

- This page size var was added starting 10.9/iOS 7, same as Swift's
aval, thus we can use it
*/
public let PAGE_SIZE = vm_kernel_page_size


//------------------------------------------------------------------------------
// MARK: GLOBAL PUBLIC STRUCTS
//------------------------------------------------------------------------------


struct libtop_i64_t {
    var accumulator : UInt64 = 0
    var last_value  : Int    = 0
}


struct libtop_i64_values_t {
    var i64               = libtop_i64_t()
    var now      : UInt64 = 0
    var began    : UInt64 = 0
    var previous : UInt64 = 0
}


/*
* Process sample information.
*
* Fields prefix meanings:
*
*   b_ : Value for first sample.
*   p_ : Value for previous sample (invalid if p_seq is 0).
*/
struct libtop_psamp_s {
    // TODO: Optionals?
    // TODO: Better init values for some metrics, -1?
    
    // TODO: These should be const right?
    var uid  : uid_t = 0 // User ID
    var pid  : pid_t = 0
    var	ppid : pid_t = 0 // Parent PID
    var pgrp : gid_t = 0 // Proc group ID
    
    /* Memory statistics. */
    var rsize      : UInt64 = 0
    var vsize      : UInt64 = 0
    var rprvt      : UInt64 = 0
    var vprvt      : UInt64 = 0
    var rshrd      : UInt64 = 0
    var fw_private : UInt64 = 0
    var empty      : UInt64 = 0
    
    var reg        : UInt32 = 0
    var p_reg      : UInt32 = 0
    
    // Previous
    var p_rsize    : UInt64 = 0
    var p_vprvt    : UInt64 = 0
    var p_vsize    : UInt64 = 0
    var p_rprvt    : UInt64 = 0
    var p_rshrd    : UInt64 = 0
    var p_empty    : UInt64 = 0
    
    /* Anonymous/purgeable memory statistics. */
    var anonymous   : UInt64 = 0
    var purgeable   : UInt64 = 0
    var p_anonymous : UInt64 = 0
    var p_purgeable : UInt64 = 0
    
    /* Compressed memory statistics. */
    var compressed   : UInt64 = 0
    var p_compressed : UInt64 = 0
    
    /* Number of threads. */
    var th   : UInt32 = 0
    var p_th : UInt32 = 0
    
    var running_th   : UInt32 = 0
    var p_running_th : UInt32 = 0
    
    
    /* Number of ports. */
    var prt   : UInt32 = 0
    var p_prt : UInt32 = 0
    
    /* CPU state/usage statistics. */
    var state : Int = 0 /* Process state. */
    
    /* Total time consumed by process. */
    var total_time   = timeval(tv_sec: 0, tv_usec: 0)
    var b_total_time = timeval(tv_sec: 0, tv_usec: 0)
    var p_total_time = timeval(tv_sec: 0, tv_usec: 0)
    
    /* Event counters. */
    var events   = task_events_info_data_t(faults: 0, pageins: 0, cow_faults: 0, messages_sent: 0, messages_received: 0, syscalls_mach: 0, syscalls_unix: 0, csw: 0)
    var b_events = task_events_info_data_t(faults: 0, pageins: 0, cow_faults: 0, messages_sent: 0, messages_received: 0, syscalls_mach: 0, syscalls_unix: 0, csw: 0)
    var p_events = task_events_info_data_t(faults: 0, pageins: 0, cow_faults: 0, messages_sent: 0, messages_received: 0, syscalls_mach: 0, syscalls_unix: 0, csw: 0)
    
    var faults        = libtop_i64_values_t()
    var pageins       = libtop_i64_values_t()
    var cow_faults    = libtop_i64_values_t()
    var messages_sent = libtop_i64_values_t()
    var messages_recv = libtop_i64_values_t()
    var syscalls_mach = libtop_i64_values_t()
    var syscalls_bsd  = libtop_i64_values_t()
    var csw           = libtop_i64_values_t()
    
    var palloc : UInt64 = 0
    var pfree  : UInt64 = 0
    var salloc : UInt64 = 0
    var sfree  : UInt64 = 0
    
    var p_palloc : UInt64 = 0
    var p_pfree  : UInt64 = 0
    var p_salloc : UInt64 = 0
    var p_sfree  : UInt64 = 0
    
    /* malloc()ed '\0'-terminated string. */
    //char			*command;
    let command = String()
    
    /* Sequence number, used to detect defunct processes. */
    var seq : UInt32 = 0
    
    /*
    * Previous sequence number, used to detect processes that have only
    * existed for the current sample (p_seq == 0).
    */ 
    var p_seq : UInt32 = 0
    
    /* time process was started */
    var started = timeval(tv_sec: 0, tv_usec: 0)
    /* process cpu type */
    var cputype : cpu_type_t = 0
    
    var wq_nthreads        : UInt32 = 0
    var wq_run_threads     : UInt32 = 0
    var wq_blocked_threads : UInt32 = 0
    
    var p_wq_nthreads        : UInt32 = 0
    var p_wq_run_threads     : UInt32 = 0
    var p_wq_blocked_threads : UInt32 = 0
    
    /* Power info. */
    var power   = task_power_info_data_t(total_user: 0, total_system: 0, task_interrupt_wakeups: 0, task_platform_idle_wakeups: 0, task_timer_wakeups_bin_1: 0, task_timer_wakeups_bin_2: 0)
    var b_power = task_power_info_data_t(total_user: 0, total_system: 0, task_interrupt_wakeups: 0, task_platform_idle_wakeups: 0, task_timer_wakeups_bin_1: 0, task_timer_wakeups_bin_2: 0)
    var p_power = task_power_info_data_t(total_user: 0, total_system: 0, task_interrupt_wakeups: 0, task_platform_idle_wakeups: 0, task_timer_wakeups_bin_1: 0, task_timer_wakeups_bin_2: 0)
}


//------------------------------------------------------------------------------
// MARK: GLOBAL PRIVATE PROPERTIES
//------------------------------------------------------------------------------


// As defined in <mach/tash_info.h>

private let HOST_BASIC_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(sizeof(host_basic_info_data_t) / sizeof(integer_t))
private let HOST_LOAD_INFO_COUNT          : mach_msg_type_number_t =
                       UInt32(sizeof(host_load_info_data_t) / sizeof(integer_t))
private let HOST_CPU_LOAD_INFO_COUNT      : mach_msg_type_number_t =
                   UInt32(sizeof(host_cpu_load_info_data_t) / sizeof(integer_t))
private let HOST_VM_INFO_COUNT            : mach_msg_type_number_t =
                        UInt32(sizeof(vm_statistics_data_t) / sizeof(integer_t))
private let HOST_VM_INFO64_COUNT          : mach_msg_type_number_t =
                      UInt32(sizeof(vm_statistics64_data_t) / sizeof(integer_t))
private let HOST_SCHED_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(sizeof(host_sched_info_data_t) / sizeof(integer_t))
private let PROCESSOR_SET_LOAD_INFO_COUNT : mach_msg_type_number_t =
              UInt32(sizeof(processor_set_load_info_data_t) / sizeof(natural_t))
private let TASK_BASIC_INFO_64_COUNT      : mach_msg_type_number_t =
                   UInt32(sizeof(task_basic_info_64_data_t) / sizeof(natural_t))
private let TASK_EVENTS_INFO_COUNT		  : mach_msg_type_number_t =
                     UInt32(sizeof(task_events_info_data_t) / sizeof(natural_t))
private let TASK_KERNELMEMORY_INFO_COUNT  : mach_msg_type_number_t =
               UInt32(sizeof(task_kernelmemory_info_data_t) / sizeof(natural_t))
private let TASK_POWER_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(sizeof(task_power_info_data_t) / sizeof(natural_t))
private let TASK_POWER_INFO_V2_COUNT	  : mach_msg_type_number_t =
                   UInt32(sizeof(task_power_info_v2_data_t) / sizeof(natural_t))
private let TASK_VM_INFO_COUNT            : mach_msg_type_number_t =
                         UInt32(sizeof(task_vm_info_data_t) / sizeof(natural_t))
private let THREAD_BASIC_INFO_COUNT       : mach_msg_type_number_t =
                    UInt32(sizeof(thread_basic_info_data_t) / sizeof(natural_t))



/**
CPU, Memory, Load, Task, Thread.
*/
public class System {
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /**
    Mach port, used for various Mach calls.
    */
    private var host : host_t
    
    private var libport : mach_port_t
    private var pset : processor_set_name_t
    private var load_prev : host_cpu_load_info? = nil
    private let memsize_t_size : size_t = UInt(sizeof(UInt64))
    
    
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
    
    
    public enum LOAD_AVG {
        /**
        5, 30, 60 second samples
        */
        case SHORT
        
        /**
        1, 5, 15 minute samples
        */
        case LONG
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() {
        host = mach_host_self()
        pset = 0
        
        libport = mach_host_self()
        
        let result = processor_set_default(host, &pset)
        
//        if (result != KERN_SUCCESS) {
//            #if DEBUG
//                println("ERROR: System class faild to init - \(result)")
//            #endif
//        }
    }

    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Close/cleanup.
    
    TODO: Can deinit do this?
    */
    public func fini() -> kern_return_t {
        return mach_port_deallocate(mach_task_self_, host)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - SYSTEM
    //--------------------------------------------------------------------------
    
    
    public func physicalCores() -> Int {
        return Int(hostBasicInfo().physical_cpu)
    }
    
    
    public func logicalCores() -> Int {
        return Int(hostBasicInfo().logical_cpu)
    }
    
    
    /**
    Get the current system CPU usage.
    */
    public func CPUUsage() -> (system: Double, user: Double, idle: Double,
                                                             nice: Double) {
            
        if (load_prev == nil) {
            println("FIRST CALL")
            load_prev = hostCPULoadInfo()
            sleep(1)
        }
        
        let load = hostCPULoadInfo()
        
        // Can't use supscript on tuple
        let user_diff = Double(load.cpu_ticks.0 - load_prev!.cpu_ticks.0)
        let sys_diff  = Double(load.cpu_ticks.1 - load_prev!.cpu_ticks.1)
        let idle_diff = Double(load.cpu_ticks.2 - load_prev!.cpu_ticks.2)
        let nice_diff = Double(load.cpu_ticks.3 - load_prev!.cpu_ticks.3)
        
        
        let totalTicks = sys_diff + user_diff + nice_diff + idle_diff
        
        var sys  = sys_diff  / totalTicks * 100
        var user = user_diff / totalTicks * 100
        var idle = idle_diff / totalTicks * 100
        var nice = nice_diff / totalTicks * 100
        
        load_prev = load
        
        // TODO: 2 decimal places
        // TODO: Check that total is 100%
        return (sys, user, idle, nice)
    }
    
    
    public func loadAverage(type : LOAD_AVG = .LONG) -> [Double] {
        var avg = [Double](count: 3, repeatedValue: 0)
        
        switch type {
            case .SHORT:
                let result = hostLoadInfo().avenrun
                avg[0] = Double(result.0) / Double(LOAD_SCALE)
                avg[1] = Double(result.1) / Double(LOAD_SCALE)
                avg[2] = Double(result.0) / Double(LOAD_SCALE)
            case .LONG:
                getloadavg(&avg, 3)
        }
        
        return avg
    }
    
    public func machFactor() -> (Double, Double, Double) {
        let result = hostLoadInfo().mach_factor
        
        return (Double(result.0) / Double(LOAD_SCALE),
                Double(result.1) / Double(LOAD_SCALE),
                Double(result.2) / Double(LOAD_SCALE))
    }
    
    public func processCount() -> Int {
        return Int(processorLoadInfo().task_count)
    }
    
    
    public func threadCount() -> Int {
        return Int(processorLoadInfo().thread_count)
    }

    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - MEMORY
    //--------------------------------------------------------------------------
    
    
    /**
    Get the size of physical memory of this machine.
    
    :returns: Size of memory. On error, 0 is returned.
    */
    public func physicalMemory(unit : Unit = .Gigabyte) -> Double {
        return Double(hostBasicInfo().max_mem) / unit.rawValue
    }
    
    
    public func memoryUsage() -> (freem: Double, active: Double, inactive: Double, wired: Double, compressed: Double) {
/*


Physical Memory: The amount of RAM installed.
Memory Used: The amount of RAM being used and not immediately available.
Virtual Memory: The amount of disk or flash drive space being used as virtual memory.
Swap Used: The space on your drive being used to swap unused files to and from RAM.
App Memory: The amount of space being used by apps.
Wired Memory: Memory that can’t be cached to disk, so it must stay in RAM. This memory can’t be borrowed by other apps.
Compressed: The amount of memory in RAM that is compressed.
File Cache: The space being used to temporarily store files that are not currently being used.
*/        
//        #if os(OSX) || (os(iOS) && arch(arm64))
//            println()
//        #endif
        let stats = VMStatistics64()
        
        let freem = Double(stats.free_count) * Double(vm_kernel_page_size) / Double(Unit.Gigabyte.rawValue)
        let active = Double(stats.active_count) * Double(vm_kernel_page_size) / Double(Unit.Gigabyte.rawValue)
        let inactive = Double(stats.inactive_count) * Double(vm_kernel_page_size) / Double(Unit.Gigabyte.rawValue)
        let wired = Double(stats.wire_count) * Double(vm_kernel_page_size) / Double(Unit.Gigabyte.rawValue)
        
        // Data size that was compressed
        let compressed = Double(stats.compressions) * Double(vm_kernel_page_size) / Double(Unit.Gigabyte.rawValue)
        
        // Result of the compression
        // This is what you see in Activity Monitor
        let compressed_result = Double(stats.compressor_page_count) * Double(vm_kernel_page_size) / Double(Unit.Gigabyte.rawValue)
        
        return (freem, active, inactive, wired, compressed_result)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    
    // Assuming x86 for now
    
    public func isProcforeign(procCPUType: cpu_type_t) -> Bool {
        // "The arch(arm) build configuration does not return true for ARM 64
        //  devices. The arch(i386) build configuration returns true when code
        //  is compiled for the 32–bit iOS simulator." ...
//        #if arch(i386) || arch(x86_64)
            return procCPUType != CPU_TYPE_X86_64 && procCPUType != CPU_TYPE_X86
//        #elseif arch(arm) || arch(arm64)
//            return procCPUType == CPU_TYPE_ARM || procCPUType == CPU_TYPE_ARM_64
//        #endif
    }
    
    
    public class func isProc64Bit(procCPUType: cpu_type_t) -> Bool {
        return procCPUType == CPU_TYPE_X86_64
    }
    
    
    private func getProcCPUType(pid: pid_t) -> cpu_type_t {
        var result :Int32 = -1
        var miblen = UInt(CTL_MAXNAME)
        // count: CTL_MAXNAME
        var mib    = [Int32](count: 12, repeatedValue:0)
        var cputype : cpu_type_t = 0
        
        result = sysctlnametomib("sysctl.proc_cputype", &mib, &miblen)
        
        if (result != 0) {
            miblen = 0
            println("1 - ERROR getting CPU type for proc")
        }
        
        if (miblen > 0) {
            mib[Int(miblen)] = pid
            var len : size_t = UInt(sizeof(cpu_type_t))
            
            result = sysctl(&mib, UInt32(miblen + UInt(1)), &cputype, &len, nil, 0)
        }
        
        if (result != 0) {
            println("2 - ERROR getting CPU type for proc")
        }
        
        return cputype
    }
    
    
    /**
    
    :returns: On error, struct with all values set to 0.
    */
    private func hostBasicInfo() -> host_basic_info {
        // TODO: Why is host_basic_info.max_mem val different from sysctl?
        
        var size = HOST_BASIC_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_BASIC_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_info(libport, HOST_BASIC_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - \(result)")
            #endif
            return host_basic_info(max_cpus         : 0,
                                   avail_cpus       : 0,
                                   memory_size      : 0,
                                   cpu_type         : 0,
                                   cpu_subtype      : 0,
                                   cpu_threadtype   : 0,
                                   physical_cpu     : 0,
                                   physical_cpu_max : 0,
                                   logical_cpu      : 0,
                                   logical_cpu_max  : 0,
                                   max_mem          : 0)
        }
        
        let data = UnsafePointer<host_basic_info>(hi).memory
        
        hi.dealloc(Int(HOST_BASIC_INFO_COUNT))
        
        return data
    }
    
    
    public func hostSchedInfo() -> host_sched_info {
        var size = HOST_SCHED_INFO_COUNT
        
        var hi = host_info_t.alloc(Int(HOST_SCHED_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_info(mach_host_self(), HOST_SCHED_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            
            // TODO: Whats timeout?
            return host_sched_info(min_timeout: 0, min_quantum: 0)
        }
        
        let data = UnsafePointer<host_sched_info>(hi).memory
        
        hi.dealloc(Int(HOST_SCHED_INFO_COUNT))
        
        return data
    }
    
    
    private func hostLoadInfo() -> host_load_info {
        //        - Can get stat from cl with w or uptime as well
        //        - getloadavg()
        //        http://en.wikipedia.org/wiki/Load_(computing)
        
        var size = HOST_LOAD_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_LOAD_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_statistics(mach_host_self(), HOST_LOAD_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            return host_load_info(avenrun: (0,0,0), mach_factor: (0,0,0))
        }
        
        let data = UnsafePointer<host_load_info>(hi).memory
        
        hi.dealloc(Int(HOST_LOAD_INFO_COUNT))
        
        return data
    }
    
    
    private func hostCPULoadInfo() -> host_cpu_load_info {
        var size = HOST_CPU_LOAD_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_CPU_LOAD_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_statistics(host, HOST_CPU_LOAD_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            return host_cpu_load_info(cpu_ticks: (0,0,0,0))
        }
        
        let data = UnsafePointer<host_cpu_load_info>(hi).memory
        
        hi.dealloc(Int(HOST_CPU_LOAD_INFO_COUNT))
        
        return data
    }
    
    
    private func processorLoadInfo() -> processor_set_load_info {
        // NOTE: duplicate load and mach factor here
        
        var count = PROCESSOR_SET_LOAD_INFO_COUNT
        var info_out = processor_set_info_t.alloc(
            Int(PROCESSOR_SET_LOAD_INFO_COUNT))
        info_out.initialize(0)
        
        
        let result = processor_set_statistics(pset, PROCESSOR_SET_LOAD_INFO,
            info_out, &count)
        
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR: \(__FUNCTION__) - \(result)")
            #endif
            
            return processor_set_load_info(task_count: 0, thread_count: 0,
                load_average: 0,
                mach_factor: 0)
        }
        
        
        // TODO: Check count size?
        let data = UnsafePointer<processor_set_load_info>(info_out).memory
        
        
        info_out.dealloc(Int(PROCESSOR_SET_LOAD_INFO_COUNT))
        
        return data
    }
    
    
    public func processList() { //-> task_array_t {
        var psets = processor_set_name_array_t.alloc(1)
        psets.initialize(0)
        var pcnt  : mach_msg_type_number_t = 0

        // Need root
        var result = host_processor_sets(mach_host_self(), &psets, &pcnt)
        if result != KERN_SUCCESS {
            // DEBUG
            // return
            println("ERROR - need root")
            return
        }
        
        
        // For each CPU
        result = host_processor_set_priv(mach_host_self(), psets[0], &pset);
        if result != KERN_SUCCESS {
            // DEBUG
            // return
            println("ERROR - get CPU")
            return
        }
        
        
        var processList = task_array_t.alloc(1)
        processList.initialize(0)
        var processCount  : mach_msg_type_number_t = 0
        result = processor_set_tasks(pset, &processList, &processCount);
        
        
        var procList : [libtop_psamp_s] = []
        
        
        // For each proc
        for var i = 0; i < Int(processCount); ++i {
            var pinfo = libtop_psamp_s()
            let process = processList[i]
            var pid : pid_t = 0
            
            
            result = pid_for_task(process, &pid)
            
            if (pid != 20849) {
                continue
            }
            
            println("PID: \(pid)")
            var kinfo_sk = kinfo_proc_systemkit(__p_starttime: timeval(tv_sec: 0, tv_usec: 0),
                                                p_flag: 0, p_stat: 0,
                                                p_comm: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                                e_ucred: _ucred(cr_ref: 0, cr_uid: 0, cr_ngroups: 0, cr_groups: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)),
                                                e_ppid: 0, e_pgid: 0)
            kinfo_for_pid(pid, &kinfo_sk)
            
            
            pinfo.uid  = kinfo_sk.e_ucred.cr_uid
            pinfo.ppid = kinfo_sk.e_ppid
            pinfo.pgrp = kinfo_sk.e_pgid
            //pinfo. = kinfo_sk.p_flag  // TODO: set this - see libtop_pinfo_s
            pinfo.started = kinfo_sk.__p_starttime
            
            pinfo.p_seq = pinfo.seq
            //pinfo.seq   = tsamp.seq  // TODO: Set this
            
            processMachPorts(process)
            processMemoryInformation(process)
            var power = processPowerInformationV2(process)
            
            println("GPU POWER: \(power.gpu_energy.task_gpu_utilisation)")
            
            var cpuType = getProcCPUType(pid)
            println("PROC TYPE: \(cpuType)")
            println("PROC Foreign: \(isProcforeign(cpuType))")
            println("PROC 64-bit: \(System.isProc64Bit(cpuType))")
            
            break
        }
    }


    private func processMemoryInformation(process: task_t) -> task_basic_info_64_data_t {
        var count = TASK_BASIC_INFO_64_COUNT
        var memoryInfo = task_info_t.alloc(Int(TASK_BASIC_INFO_64_COUNT))

        var result = task_info(process, UInt32(TASK_BASIC_INFO_64), memoryInfo, &count)

        if (result != KERN_SUCCESS) {
            // TODO: Or maybe just return memoryInfo?
            // TODO: Should we return result as well?
            return task_basic_info_64_data_t(suspend_count: 0,
                                             virtual_size: 0,
                                             resident_size: 0,
                                             user_time: time_value_t(seconds: 0, microseconds: 0),
                                             system_time: time_value_t(seconds: 0, microseconds: 0),
                                             policy: 0)
        }

        let data = UnsafePointer<task_basic_info_64_data_t>(memoryInfo).memory
        
        memoryInfo.dealloc(Int(TASK_BASIC_INFO_64_COUNT))
        
        println("VIRT MEM: \(data.virtual_size)")
        
        return data

    }
    
    
    /**
    Wired memory usage
    */
    private func processKerenlMemoryInformation(process: task_t) {
        /*
        kern_return_t kr;
        
        mach_msg_type_number_t count = TASK_KERNELMEMORY_INFO_COUNT;
        
        pinfo->psamp.p_palloc = pinfo->psamp.palloc;
        pinfo->psamp.p_pfree = pinfo->psamp.pfree;
        pinfo->psamp.p_salloc = pinfo->psamp.salloc;
        pinfo->psamp.p_sfree = pinfo->psamp.sfree;
        
        kr = task_info(task, TASK_KERNELMEMORY_INFO, (task_info_t)&pinfo->psamp.palloc, &count);
        return kr;
        */
        
        
        var result: kern_return_t
        var count: mach_msg_type_number_t = TASK_KERNELMEMORY_INFO_COUNT
        
        // TODO: Why just palloc?
        var palloc = task_info_t.alloc(Int(TASK_KERNELMEMORY_INFO_COUNT))
        
        result = task_info(process, TASK_KERNELMEMORY_INFO_COUNT, palloc, &count)
        
        if result != KERN_SUCCESS {
            return
        }
        
        let data = UnsafePointer<task_power_info_data_t>(palloc).memory
        
        palloc.dealloc(Int(TASK_KERNELMEMORY_INFO_COUNT))
        
        //return data
        
    }
    
    
    /**
    Number of Mach ports
    */
    private func processMachPorts(process : task_t) {
        // http://www.gnu.org/software/hurd/gnumach-doc/Port-Names.html
        /*
        kern_return_t kr;
        mach_msg_type_number_t ncnt, tcnt;
        mach_port_name_array_t names;
        mach_port_type_array_t types;
        
        pinfo->psamp.p_prt = pinfo->psamp.prt;
        
        kr = mach_port_names(task, &names, &ncnt, &types, &tcnt);
        if (kr != KERN_SUCCESS) return 0;
        
        pinfo->psamp.prt = ncnt;
        
        kr = mach_vm_deallocate(mach_task_self(), (mach_vm_address_t)(uintptr_t)names, ncnt * sizeof(*names));
        kr = mach_vm_deallocate(mach_task_self(), (mach_vm_address_t)(uintptr_t)types, tcnt * sizeof(*types));
        */
        
        var result: kern_return_t
        var ncnt: mach_msg_type_number_t = 0
        var tcnt: mach_msg_type_number_t = 0
        var names = mach_port_name_array_t.alloc(1)
        var types = mach_port_type_array_t.alloc(1)
        
        // UnsafeMutablePointer<mach_port_name_array_t>
        result = mach_port_names(process, &names, &ncnt, &types, &tcnt)
        
        if (result != KERN_SUCCESS) {
            println("PORT CALL: \(result)")
            return
        }
    
        println("PORT COUNT: \(ncnt)")

        // http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/vm_deallocate.html
        // sizeof(*names) = 4
        var address: mach_vm_address_t = UnsafePointer<mach_vm_address_t>(names).memory
        result = mach_vm_deallocate(mach_task_self_, address, UInt64(ncnt) * UInt64(sizeof(mach_port_name_t)))
        
        println("DEALLOC: \(result)")
    }
    
    
    private func processPowerInformation(process : task_t) -> task_power_info_data_t {
        var count = TASK_POWER_INFO_COUNT
        var powerInfo = task_info_t.alloc(Int(TASK_POWER_INFO_COUNT))
        var result = task_info(process, UInt32(TASK_POWER_INFO), powerInfo, &count)
        
        if result != KERN_SUCCESS {
            return task_power_info_data_t(total_user                 : 0,
                                          total_system               : 0,
                                          task_interrupt_wakeups     : 0,
                                          task_platform_idle_wakeups : 0,
                                          task_timer_wakeups_bin_1   : 0,
                                          task_timer_wakeups_bin_2   : 0)
        }
        
        let data = UnsafePointer<task_power_info_data_t>(powerInfo).memory
        
        powerInfo.dealloc(Int(TASK_POWER_INFO_COUNT))
        
        return data
    }
    
    
    private func processPowerInformationV2(process: task_t) -> task_power_info_v2_data_t {
        // Doesn't seem to work. Maybe need a newer GPU? Discrete GPU?
        // GPU - Returns the total gpu time used by the all the threads of the task
        
        var count = TASK_POWER_INFO_V2_COUNT
        var powerInfo = task_info_t.alloc(Int(TASK_POWER_INFO_V2_COUNT))
        var result = task_info(process, UInt32(TASK_POWER_INFO_V2), powerInfo, &count)
        
        if result != KERN_SUCCESS {
           let temp = task_power_info_data_t(total_user                 : 0,
                            total_system               : 0,
                            task_interrupt_wakeups     : 0,
                            task_platform_idle_wakeups : 0,
                            task_timer_wakeups_bin_1   : 0,
                            task_timer_wakeups_bin_2   : 0)
            let gpu_temp = gpu_energy_data(task_gpu_utilisation: 0, task_gpu_stat_reserved0: 0, task_gpu_stat_reserved1: 0, task_gpu_stat_reserved2: 0)
            return task_power_info_v2_data_t(cpu_energy: temp, gpu_energy: gpu_temp)

        }
        
        let data = UnsafePointer<task_power_info_v2_data_t>(powerInfo).memory
        
        powerInfo.dealloc(Int(TASK_POWER_INFO_V2_COUNT))
        
        return data
    }
    
    
    /**
    32-bit virtual memory statistics. Used for 32-bit iOS devices.
    */
    public func VMStatistics() -> vm_statistics {
        // This doesn't give you swap, may have to get it from sysctl
        var size = HOST_VM_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_VM_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_statistics(host, HOST_VM_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t ="
                        + " \(result)")
            #endif
            return vm_statistics(free_count: 0,
                                 active_count      : 0,
                                 inactive_count    : 0,
                                 wire_count        : 0,
                                 zero_fill_count   : 0,
                                 reactivations     : 0,
                                 pageins           : 0,
                                 pageouts          : 0,
                                 faults            : 0,
                                 cow_faults        : 0,
                                 lookups           : 0,
                                 hits              : 0,
                                 purgeable_count   : 0,
                                 purges            : 0,
                                 speculative_count : 0)
        }
        
        let data = UnsafePointer<vm_statistics>(hi).memory
        
        hi.dealloc(Int(HOST_VM_INFO_COUNT))
        
        return data
    }
    
    
    /**
    64-bit virtual memory statistics. This should apply to all Mac's that run
    10.9 and above, and iPhone 5S and on, and iPad Air & iPad Mini 2 and on.
    // Swift runs on 10.9 and above, and 10.9 is x86_64 only. On iOS though
    // its 7 and above, with both ARM & ARM64
    // TODO: Does iOS 32-bit have supported for commpressed memory?
    // TODO: For now we have two methods, but we could use arch macros
    */
    public func VMStatistics64() -> vm_statistics64 {
        var size = HOST_VM_INFO64_COUNT
        var hi = host_info_t.alloc(Int(HOST_VM_INFO64_COUNT))
        hi.initialize(0)
        
        let result = host_statistics64(host, HOST_VM_INFO64, hi, &size)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t ="
                        + " \(result)")
            #endif
            return vm_statistics64(free_count                             : 0,
                                   active_count                           : 0,
                                   inactive_count                         : 0,
                                   wire_count                             : 0,
                                   zero_fill_count                        : 0,
                                   reactivations                          : 0,
                                   pageins                                : 0,
                                   pageouts                               : 0,
                                   faults                                 : 0,
                                   cow_faults                             : 0,
                                   lookups                                : 0,
                                   hits                                   : 0,
                                   purges                                 : 0,
                                   purgeable_count                        : 0,
                                   speculative_count                      : 0,
                                   decompressions                         : 0,
                                   compressions                           : 0,
                                   swapins                                : 0,
                                   swapouts                               : 0,
                                   compressor_page_count                  : 0,
                                   throttled_count                        : 0,
                                   external_page_count                    : 0,
                                   internal_page_count                    : 0,
                                   total_uncompressed_pages_in_compressor : 0)
        }
        
        let data = UnsafePointer<vm_statistics64>(hi).memory
        
        hi.dealloc(Int(HOST_VM_INFO64_COUNT))
        
        return data
    }
}
