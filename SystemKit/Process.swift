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

/// Process information
public struct ProcessInfo {
    let pid     : Int
    let command : String
    
    public init(pid: Int, command: String) {
        self.pid = pid
        self.command = command
    }
}


/// Process API
public struct Process {
    
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
                var pid : pid_t = 0
                
                result = pid_for_task(process, &pid)
                
                
                var kinfoProc = kinfo_proc_systemkit(__p_starttime: timeval(tv_sec: 0, tv_usec: 0),
                                                     p_flag: 0,
                                                     p_stat: 0,
                                                     p_comm: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                                     e_ucred: _ucred(cr_ref: 0, cr_uid: 0, cr_ngroups: 0,
                                                                     cr_groups: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)),
                                                     e_ppid: 0,
                                                     e_pgid: 0)
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

                println("PID: \(pid); \(procCommand)")
                
                
                var procInfo = ProcessInfo(pid: Int(pid), command: procCommand)
                processInfo.append(procInfo)
            }
        }
        
        return processInfo
    }
}

