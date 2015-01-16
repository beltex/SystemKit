//
// Process.swift
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

//--------------------------------------------------------------------------
// MARK: PUBLIC GLOBAL PROPERTIES
//--------------------------------------------------------------------------

// As defined in <mach/machine.h>

/// Assuming this is interpreted as unknown for now
public let CPU_TYPE_ANY       : cpu_type_t = -1
public let CPU_TYPE_X86       : cpu_type_t = 7
public let CPU_TYPE_I386      : cpu_type_t = CPU_TYPE_X86   // For compatibility
public let CPU_TYPE_X86_64    : cpu_type_t = CPU_TYPE_X86 | CPU_ARCH_ABI64
public let CPU_TYPE_ARM       : cpu_type_t = 12
public let CPU_TYPE_ARM64     : cpu_type_t = CPU_TYPE_ARM | CPU_ARCH_ABI64
public let CPU_TYPE_POWERPC   : cpu_type_t = 18
public let CPU_TYPE_POWERPC64 : cpu_type_t = CPU_TYPE_POWERPC | CPU_ARCH_ABI64


/// Process information
public struct ProcessInfo {
    
    let pid     : Int
    let ppid    : Int
    let pgid    : Int
    let uid     : Int
    let command : String
    /// What architecture was this process compiled for?
    let arch    : cpu_type_t
    /// sys/proc.h - SIDL, SRUN, SSLEEP, SSTOP, SZOMB
    var status  : Int32
    
    
    public init(pid: Int, ppid: Int, pgid: Int, uid: Int, command: String,
                                                             arch: cpu_type_t,
                                                           status: Int32) {
        self.pid     = pid
        self.ppid    = ppid
        self.pgid    = pgid
        self.uid     = uid
        self.command = command
        self.arch    = arch
        self.status  = status
    }
}


/// Process API
public struct Process {
    
    private static let MACH_TASK_BASIC_INFO_COUNT: mach_msg_type_number_t =
                 UInt32(sizeof(mach_task_basic_info_data_t) / sizeof(natural_t))

    
    public init() { }
    
    public static func list() -> [ProcessInfo] {
        var processInfo = [ProcessInfo]()
        
        var pset: processor_set_name_t = 0
        var result = processor_set_default(mach_host_self(), &pset)
        
        if result != KERN_SUCCESS {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - " +
                        "processor_set_default")
            #endif
            return processInfo
        }
        
        
        var psets = processor_set_name_array_t.alloc(1)
        psets.initialize(0)
        var pcnt: mach_msg_type_number_t = 0
        
        // Need root
        result = host_processor_sets(mach_host_self(), &psets, &pcnt)
        if result != KERN_SUCCESS {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - Need root - " +
                        "kern_return_t: \(result)")
            #endif
            return processInfo
        }
        
        
        // TODO: For each CPU?
        for var i = 0; i < Int(pcnt); ++i {
            result = host_processor_set_priv(mach_host_self(), psets[i], &pset);
            
            if result != KERN_SUCCESS {
                #if DEBUG
                    println("ERROR - \(__FILE__):\(__FUNCTION__) - CPU \(i)")
                #endif
                return processInfo
            }
            
            println("CPU \(i) GOOD")
            
            
            var processList = task_array_t.alloc(1)
            processList.initialize(0)
            
            var processCount: mach_msg_type_number_t = 0
            result = processor_set_tasks(pset, &processList, &processCount)
            
            println("PROC COUNT: \(processCount)")
            
            
            // For each process
            for var i = 0; i < Int(processCount); ++i {
                let process = processList[i]
                var pid: pid_t = 0
                
                result = pid_for_task(process, &pid)
                
                // BSD layer only stuff
                var kinfoProc = kinfo_proc_systemkit(p_stat: 0,
                                                     p_comm: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                                     e_ppid: 0,
                                                     e_pgid: 0,
                                                        uid: 0)
                kinfo_for_pid(pid, &kinfoProc)
                
                
                var procCommand = String()
                
                // FIXME: Very bad
                // TODO: Command cut short?
                if kinfoProc.p_comm.0  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.0))))  }
                if kinfoProc.p_comm.1  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.1))))  }
                if kinfoProc.p_comm.2  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.2))))  }
                if kinfoProc.p_comm.3  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.3))))  }
                if kinfoProc.p_comm.4  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.4))))  }
                if kinfoProc.p_comm.5  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.5))))  }
                if kinfoProc.p_comm.6  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.6))))  }
                if kinfoProc.p_comm.7  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.7))))  }
                if kinfoProc.p_comm.8  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.8))))  }
                if kinfoProc.p_comm.9  > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.9))))  }
                if kinfoProc.p_comm.10 > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.10)))) }
                if kinfoProc.p_comm.11 > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.11)))) }
                if kinfoProc.p_comm.12 > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.12)))) }
                if kinfoProc.p_comm.13 > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.13)))) }
                if kinfoProc.p_comm.14 > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.14)))) }
                if kinfoProc.p_comm.15 > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.15)))) }
                if kinfoProc.p_comm.16 > 0 { procCommand.append(Character(UnicodeScalar(Int(kinfoProc.p_comm.16)))) }

                println("PID: \(pid); \(procCommand); CPU TYPE: \(arch(pid))")
//                        "PPID: \(kinfoProc.e_ppid); " +
//                        "PGID: \(kinfoProc.e_pgid); " +
//                        "UID: \(kinfoProc.uid); " +
//                        "STATUS: \(kinfoProc.p_stat)")
                
                var machTask = machTaskBasicInfo(process)
                
                var tv = timeval(tv_sec: Int(0), tv_usec: 0)
                var tvp = timeval(tv_sec: Int(machTask.user_time.seconds), tv_usec: Int32(machTask.user_time.microseconds))
                var uvp = timeval(tv_sec: Int(machTask.system_time.seconds), tv_usec: Int32(machTask.system_time.microseconds))
                timeradd(tvp, uvp: uvp, vvp: &tv)
                println("TIME: \(timeFormat(tv))")
                
                var procInfo = ProcessInfo(pid: Int(pid),
                                           ppid: Int(kinfoProc.e_ppid),
                                           pgid: Int(kinfoProc.e_pgid),
                                           uid: Int(kinfoProc.uid),
                                           command: procCommand,
                                           arch: arch(pid),
                                           status: Int32(kinfoProc.p_stat))
                processInfo.append(procInfo)
            }
        }
        
        return processInfo
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    
    private static func machTaskBasicInfo(process: task_t) -> mach_task_basic_info {
        // NOTE: top uses TASK_BASIC_INFO_64 instead, but the mach/task_info.h
        //       suggests to use MACH_TASK_BASIC_INFO instead
        var count = MACH_TASK_BASIC_INFO_COUNT
        var memoryInfo = task_info_t.alloc(Int(MACH_TASK_BASIC_INFO_COUNT))
        memoryInfo.initialize(0)
        
        var result = task_info(process, UInt32(MACH_TASK_BASIC_INFO), memoryInfo, &count)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            #endif
            return mach_task_basic_info(virtual_size: 0,
                                        resident_size: 0,
                                        resident_size_max: 0,
                                        user_time: time_value_t(seconds: 0, microseconds: 0),
                                        system_time: time_value_t(seconds: 0, microseconds: 0),
                                        policy: 0,
                                        suspend_count: 0)
        }
        
        let data = UnsafePointer<mach_task_basic_info>(memoryInfo).memory
        
        memoryInfo.dealloc(Int(MACH_TASK_BASIC_INFO_COUNT))
                
        return data
    }
    
    
    public static func arch(pid: pid_t) -> cpu_type_t {
        var arch: cpu_type_t = CPU_TYPE_ANY
        
        // "sysctl.proc_cputype" not documented anywhere. Doesn't even show
        // up when doing sysctl -A. But you can see it if you run sysctl sysctl.
        // Hard coding it does carry a risk, as it could change down the road.
        // Hence, top calls sysctlnametomib() first
        var mib: [Int32] = [0, 103, pid]
        var len: size_t = UInt(sizeof(cpu_type_t))
        
        let result = sysctl(&mib, UInt32(mib.count), &arch, &len, nil, 0)
        
        #if DEBUG
            if result != 0 {
                println("ERROR - \(__FILE__):\(__FUNCTION__):\(__LINE__)")
            }
        #endif
        
        return arch
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS - HELPERS
    //--------------------------------------------------------------------------
    
    
    /// Based on macro of the same name from sys/time.h
    private static func timeradd(tvp: timeval, uvp: timeval, inout vvp: timeval) {
        vvp.tv_sec  = tvp.tv_sec + uvp.tv_sec
        vvp.tv_usec = tvp.tv_usec + uvp.tv_usec
        if (vvp.tv_usec >= 1000000) {
            vvp.tv_sec++
            vvp.tv_usec -= 1000000
        }
    }
    
    
    private static func timeFormat(tv: timeval) -> String {
        var timeFormatted = String()
        
        let usec = tv.tv_usec
        let sec  = tv.tv_sec
        let min  = sec  / 60
        let hour = min  / 60
        let day  = hour / 24
        
        if (min < 100) {
            return NSString(format: "%02u:%02u.%02u", min, sec % 60, usec / 10000)
        }
        else if (hour < 100) {
            return  NSString(format: "%02u:%02u:%02u", hour, min % 60, sec % 60)
        }
        else { return NSString(format: "%u hrs", hour) }
    }
}
