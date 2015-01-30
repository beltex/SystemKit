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

//------------------------------------------------------------------------------
// MARK: GLOBAL PUBLIC PROPERTIES
//------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------
// MARK: PUBLIC STRUCTS
//------------------------------------------------------------------------------

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
}

/// Process API
public struct Process {
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------

    private static let machHost = mach_host_self()
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------
    
    public init() { }
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    /// Return list of currently running processes
    public static func list() -> [ProcessInfo] {
        var list                         = [ProcessInfo]()
        var psets                        = processor_set_name_array_t.alloc(1)
        var pcnt: mach_msg_type_number_t = 0

        // Need root
        var result = host_processor_sets(machHost, &psets, &pcnt)
        if result != KERN_SUCCESS {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - Need root - " +
                        "kern_return_t: \(result)")
            #endif
            return list
        }
        
        
        // For each CPU set
        for var i = 0; i < Int(pcnt); ++i {
            var pset: processor_set_name_t = 0
            result = host_processor_set_priv(machHost, psets[i], &pset)
            
            if result != KERN_SUCCESS {
                #if DEBUG
                    println("ERROR - \(__FILE__):\(__FUNCTION__) - CPU set " +
                            "\(i) - kern_return_t: \(result)")
                #endif
                continue
            }
            
            
            // Get port to each task
            var tasks                             = task_array_t.alloc(1)
            var taskCount: mach_msg_type_number_t = 0
            result = processor_set_tasks(pset, &tasks, &taskCount)
            
            if result != KERN_SUCCESS {
                #if DEBUG
                    println("ERROR - \(__FILE__):\(__FUNCTION__) - failed to "
                            + " get tasks - kern_return_t: \(result)")
                #endif
                continue
            }

            
            // For each task
            for var x = 0; x < Int(taskCount); ++x {
                let task       = tasks[x]
                var pid: pid_t = 0
                
                pid_for_task(task, &pid)
                
                
                // BSD layer only stuff
                var kinfoProc = kinfo_proc_systemkit(
                                    p_stat: 0,
                                    p_comm: (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
                                    e_ppid: 0,
                                    e_pgid: 0,
                                       uid: 0)
                
                kinfo_for_pid(pid, &kinfoProc)

                let command = withUnsafePointer(&kinfoProc.p_comm) {
                    String.fromCString(UnsafePointer($0))!
                }
                
                
                list.append(ProcessInfo(pid    : Int(pid),
                                        ppid   : Int(kinfoProc.e_ppid),
                                        pgid   : Int(kinfoProc.e_pgid),
                                        uid    : Int(kinfoProc.uid),
                                        command: command,
                                        arch   : arch(pid),
                                        status : Int32(kinfoProc.p_stat)))
                
                mach_port_deallocate(mach_task_self_, task)
            }
            
            // TODO: Missing deallocate for tasks
            mach_port_deallocate(mach_task_self_, pset)
            mach_port_deallocate(mach_task_self_, psets[i])
            
            // TODO: Why do dealloc calls on tasks and psets fail?
        }
        
        return list
    }

    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    /// What architecture was this process compiled for?
    private static func arch(pid: pid_t) -> cpu_type_t {
        var arch = CPU_TYPE_ANY
        
        // TODO: "sysctl.proc_cputype" not documented anywhere. Doesn't even
        // show up when doing sysctl -A. But you can see it if you run
        // "sysctl sysctl". Hard coding it does carry a risk, as it could change
        // down the road. Hence, top calls sysctlnametomib() first
        var mib: [Int32] = [0, 103, pid]
        var len          = size_t(sizeof(cpu_type_t))
        
        let result = sysctl(&mib, u_int(mib.count), &arch, &len, nil, 0)
        
        #if DEBUG
            if result != 0 {
                println("ERROR - \(__FILE__):\(__FUNCTION__):\(__LINE__)")
            }
        #endif
        
        return arch
    }
}
