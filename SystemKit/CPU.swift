
import Darwin
import Foundation


/**
API to read stats about the CPU.
*/
public class CPU {
    
    
    private let HOST_BASIC_INFO_COUNT : mach_msg_type_number_t = UInt32(sizeof(host_basic_info_data_t) / sizeof(integer_t))
    
    
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
    
    
    public func logicalCores() -> Int {
        var size = HOST_BASIC_INFO_COUNT
        var hi = host_info_t.alloc(Int(HOST_BASIC_INFO_COUNT))
        hi.initialize(0)
        
        let result = host_info(mach_host_self(), HOST_BASIC_INFO, hi, &size)
        
        if (result != KERN_SUCCESS) {
            println("ERROR: \(__FUNCTION__) - \(result)")
            return 0
        }
        
        let data = UnsafePointer<host_basic_info>(hi)
        
        let ans = Int(data.memory.logical_cpu)
        
        hi.dealloc(Int(HOST_BASIC_INFO_COUNT))
        return ans
    }
    
    
    public func physicalCores() -> Int {
        return 0
    }
}