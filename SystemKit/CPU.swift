
import Darwin
import Foundation


/**
API to read stats about the CPU.
*/
public class CPU {
    
    
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
    
    
    public func numCores() -> Int {
        return 0
    }
}