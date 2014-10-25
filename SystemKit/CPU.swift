
import Darwin
import Foundation


/**
API to read stats about the CPU.
*/
public class CPU {
    
    
    private let HOST_BASIC_INFO_COUNT : mach_msg_type_number_t = UInt32(sizeof(host_basic_info_data_t) / sizeof(integer_t))
    
    
    private let HOST_LOAD_INFO_COUNT: mach_msg_type_number_t = UInt32(sizeof(host_load_info_data_t)/sizeof(integer_t))
    
    
    private let HOST_CPU_LOAD_INFO_COUNT : mach_msg_type_number_t = UInt32(sizeof (host_cpu_load_info_data_t) / sizeof (integer_t))
    
    
    private var load_prev : host_cpu_load_info? = nil
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Get the system load average.
    
    - Can get stat from cl with w or uptime as well
    
    http://en.wikipedia.org/wiki/Load_(computing)
    */
    public func loadAvg() -> [Double] {
        // TODO: Round to two decmial places
        
        var avg = [Double](count: 3, repeatedValue: 0)
        
        getloadavg(&avg, Int32(sizeof(Double) * 3))
        
        return avg
    }
    
    
    public func hostBasicInfo() -> host_basic_info {
        // TODO: Why is host_basic_info.max_mem val different from sysctl?
        
        var size = HOST_BASIC_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_BASIC_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_info(mach_host_self(), HOST_BASIC_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            return host_basic_info(max_cpus: 0, avail_cpus: 0,
                                                memory_size: 0,
                                                cpu_type: 0,
                                                cpu_subtype: 0,
                                                cpu_threadtype: 0,
                                                physical_cpu: 0,
                                                physical_cpu_max: 0,
                                                logical_cpu: 0,
                                                logical_cpu_max: 0,
                                                max_mem: 0)
        }
        
        let data = UnsafePointer<host_basic_info>(hi).memory
        
        hi.dealloc(Int(HOST_BASIC_INFO_COUNT))
        
        return data
    }
    
    
    public func hostStatistics() -> host_load_info {
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
    
    
    public func cpuLoadInfo() -> host_cpu_load_info {
        var size = HOST_CPU_LOAD_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_CPU_LOAD_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            return host_cpu_load_info(cpu_ticks: (0,0,0,0))
        }
        
        let data = UnsafePointer<host_cpu_load_info>(hi).memory
        
        hi.dealloc(Int(HOST_CPU_LOAD_INFO_COUNT))
        
        return data
    }
    
    
    public func cpuUsage() -> (sys: Double, user: Double, idle: Double,
                                                          nice: Double) {
        
        if (load_prev == nil) {
            println("FIRST CALL")
            load_prev = cpuLoadInfo()
            sleep(1)
        }
    
        let load = cpuLoadInfo()
    
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
    
    
    public func logicalCores() -> Int {
        return Int(hostBasicInfo().logical_cpu)
    }
    
    
    public func physicalCores() -> Int {
        return Int(hostBasicInfo().physical_cpu)
    }
}