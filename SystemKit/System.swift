
import Darwin
import Foundation

/**
Overall system related API.

TODO: Maybe move CPU, Memory, and Process classes all into here?
*/
public class System {
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC PROPERTIES
    //--------------------------------------------------------------------------
    
    
    public let PAGE_SIZE = vm_kernel_page_size

    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    
    
    // Swift can't handle complex macros, thus we import these manually
    
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
    
    
    private var host : host_t
    private var pset : processor_set_name_t
    private var load_prev : host_cpu_load_info? = nil
    
    
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
    
    
    //--------------------------------------------------------------------------
    // MARK: INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() {
        host = mach_host_self()
        pset = 0
        
        let result = processor_set_default(host, &pset)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR: System class faild to init - \(result)")
            #endif
        }
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
    
    
    /**
    Basically gives the whole ouput of uname -a

    */
    public func kernelVersion() -> String {
        let kern_version_t_size = Int(sizeof(kernel_version_t))
        var version = String()
            
        var ptr = UnsafeMutablePointer<Int8>.alloc(kern_version_t_size)
        ptr.initialize(0)
        
        let result = host_kernel_version(mach_host_self(), ptr)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_return_t ="
                        + " \(result)")
            #endif
            return version
        }
        
        
        // Iterate through the array to get all the chars
        for var i = 0; i < kern_version_t_size; ++i {
            // Check if at the end
            if (ptr[i] <= 0) {
                break
            }
            
            version.append(UnicodeScalar(UInt32(ptr[i])))
        }
        
        
        return version
    }
    
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - MEMORY
    //--------------------------------------------------------------------------

    
    private let memsize_t_size : size_t = UInt(sizeof(UInt64))
    
    
    public func vmStatistics() -> vm_statistics {
        var size = HOST_VM_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_VM_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_statistics(mach_host_self(), HOST_VM_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            return vm_statistics(free_count: 0,
                active_count: 0,
                inactive_count: 0,
                wire_count: 0,
                zero_fill_count: 0,
                reactivations: 0,
                pageins: 0,
                pageouts: 0,
                faults: 0,
                cow_faults: 0,
                lookups: 0,
                hits: 0,
                purgeable_count: 0,
                purges: 0,
                speculative_count: 0)
        }
        
        let data = UnsafePointer<vm_statistics>(hi).memory
        
        hi.dealloc(Int(HOST_VM_INFO_COUNT))
        
        return data
    }
    
    
    public func vmStatistics64() -> vm_statistics64 {
        // Swift runs on 10.9 and above, and 10.9 is x86_64 only. On iOS though
        // its 7 and above, with both ARM & ARM64
        // TODO: Does iOS 32-bit have supported for commpressed memory?
        // TODO: For now we have two methods, but we could use arch macros
        
        var size = HOST_VM_INFO64_COUNT
        var hi = host_info_t.alloc(Int(HOST_VM_INFO64_COUNT))
        hi.initialize(0)
        
        let result = host_statistics64(mach_host_self(), HOST_VM_INFO64, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            return vm_statistics64(free_count: 0,
                active_count: 0,
                inactive_count: 0,
                wire_count: 0,
                zero_fill_count: 0,
                reactivations: 0,
                pageins: 0,
                pageouts: 0,
                faults: 0,
                cow_faults: 0,
                lookups: 0,
                hits: 0,
                purges: 0,
                purgeable_count: 0,
                speculative_count: 0,
                decompressions: 0,
                compressions: 0,
                swapins: 0,
                swapouts: 0,
                compressor_page_count: 0,
                throttled_count: 0,
                external_page_count: 0,
                internal_page_count: 0,
                total_uncompressed_pages_in_compressor: 0)
        }
        
        let data = UnsafePointer<vm_statistics64>(hi).memory
        
        hi.dealloc(Int(HOST_VM_INFO64_COUNT))
        
        return data
    }
    
    
    public func usage() -> (freem: Double, active: Double, inactive: Double, wired: Double, compressed: Double) {
        let stats = vmStatistics64()
        
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
    
    
    /**
    Get the default page size for the system.
    
    - Can check this via pagesize shell command as well
    - C lib function getpagesize()
    - host_page_size()
    // This page size var was added starting 10.9, and iOS 7, same as
    // Swift's aval, thus we can use it
    
    :returns: System default page size in bytes
    */
    public func pageSize(unit : Unit = Unit.Byte) -> Double {

        return Double(vm_kernel_page_size) / unit.rawValue
    }
    
    
    /**
    Get the physical size of memory for this machine.
    
    
    :params: Optional unit value for return. Defaults to GB.
    :returns: The size as bytes
    */
    public func physicalSize(unit : Unit = .Gigabyte) -> Double {
        var memsize : UInt64 = 0
        var opts = [CTL_HW, HW_MEMSIZE]
        var size = memsize_t_size
        
        let result = sysctl(&opts, 2, &memsize, &size, nil, 0)
        
        if (result != KERN_SUCCESS) {
            #if DEBUG
                println("ERROR: \(__FUNCTION__) - \(result)")
            #endif
            
            return 0
        }
        
        return Double(memsize) / unit.rawValue
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS - SYSTEM
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
    
    
    
    public func loadInfo() -> processor_set_load_info {
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
    
    
    /**
    Get the total number of processes (tasks in Mach parlance) running.
    */
    public func processCount() -> Int32 {
        return loadInfo().task_count
    }
    
    
    /**
    Get the total number of threads running.
    */
    public func threadCount() -> Int32 {
        return loadInfo().thread_count
    }
    
    

    
    
    public func schedInfo() -> host_sched_info {
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

    
    // TODO: can we get this for 3 time ranges?
    public func machFactor() -> Double {
        return Double(loadInfo().mach_factor) / Double(LOAD_SCALE)
    }
}