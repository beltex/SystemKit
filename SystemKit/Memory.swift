
import Darwin
import Foundation

/**
Memory API.
*/
public class Memory {
    // TODO: Option for units? bytes, kb, mb, gb ?
    
    
    /**
    Unit options for method data returns.
    
    TODO: Move this to a central place
    */
    public enum Unit : Double {
        // For going from byte to -
        case Byte     = 1
        case Kilobyte = 1024
        case Megabyte = 1048576
        case Gigabyte = 1073741824
    }
    
    
    private let HOST_VM_INFO_COUNT : mach_msg_type_number_t = UInt32(sizeof(vm_statistics_data_t) / sizeof(integer_t))
    
    private let HOST_VM_INFO64_COUNT : mach_msg_type_number_t = UInt32(sizeof(vm_statistics64_data_t) / sizeof(integer_t))
    
    
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
    
    
    /**
    Get the default page size for the system.
    
    - Can check this via pagesize shell command as well
    - C lib function getpagesize()
    
    :returns: System default page size in bytes
    */
    public func pageSize(unit : Unit = Unit.Byte) -> Double {
        var port      : mach_port_t = mach_host_self()
        var pageSize  : vm_size_t   = 0
        
        // Check return if debug on?
        host_page_size(port, &pageSize)
        
        return Double(pageSize) / unit.rawValue
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
}