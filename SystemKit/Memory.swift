
import Darwin
import Foundation

/**
Memory API.
*/
public class Memory {
    // TODO: Option for units? bytes, kb, mb, gb ?
    
    
    /**
    Get the default page size for the system.
    
    - Can check this via pagesize shell command as well
    - C lib function getpagesize()
    
    :returns: System default page size in bytes
    */
    public func pageSize() -> UInt {
        var port      : mach_port_t = mach_host_self()
        var pageSize  : vm_size_t   = 0
        
        // Check return if debug on?
        host_page_size(port, &pageSize)
        
        return pageSize
    }
    
    
    /**
    Get the physical size of memory for this machine.
    
    :returns: The size as bytes
    */
    public func physicalSize() -> UInt64 {
        var opts = [CTL_HW, HW_MEMSIZE]
        var size : size_t = UInt(sizeof(UInt64))
        var memsize : UInt64 = 0
        
        // Why does this return 8.5 GB?
        var result = sysctl(&opts, 2, &memsize, &size, nil, 0)
        
        if (result == -1) {
            println("Error getting physical mem size")
        }
        else {
            println("Mem size: \(memsize)")
        }
        
        return memsize
    }
}