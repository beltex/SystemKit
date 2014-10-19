
import Darwin
import Foundation

/**
Overall system related API.

TODO: Maybe move CPU, Memory, and Process classes all into here?
*/
public class System {
    
    // Because Swift can't handle complex macros - move this to a centeral places with the rest
    public let PROCESSOR_SET_LOAD_INFO_COUNT : mach_msg_type_number_t = UInt32(sizeof(processor_set_load_info_data_t) / sizeof(natural_t))
    
    
    var host : host_t
    var pset : processor_set_name_t
    
    
    
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
    
    
    /**
    Close/cleanup.
    
    TODO: Can deinit do this?
    */
    public func fini() -> kern_return_t {
        return mach_port_deallocate(mach_task_self_, host)
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
        let data = processor_set_load_info(task_count: info_out[0],
                                           thread_count: info_out[1],
                                           load_average: info_out[2],
                                           mach_factor: info_out[3])
    
        
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
    
    
    // TODO: Over what time range are these two loads over?
    
    
    public func loadAvg() -> Double {
        return Double(loadInfo().load_average) / Double(LOAD_SCALE)
    }
    
    
    public func machFactor() -> Double {
        return Double(loadInfo().mach_factor) / Double(LOAD_SCALE)
    }
}