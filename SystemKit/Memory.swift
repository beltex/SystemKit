
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
    
    
    private let memsize_t_size : size_t = UInt(sizeof(UInt64))
    
    
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
    public func physicalSize(unit : Unit = Unit.Gigabyte) -> Double {
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