import IOKit

enum IOReturn : kern_return_t {
    case kIOReturnSuccess          = 0      // KERN_SUCCESS - OK
    case kIOReturnError            = 0x2bc  // General error
    case kIOReturnNoMemory         = 0x2bd  // Can't allocate memory
    case kIOReturnNoResources      = 0x2be  // Resource shortage
    case kIOReturnIPCError         = 0x2bf  // Error during IPC
    case kIOReturnNoDevice         = 0x2c0  // No such device
    case kIOReturnNotPrivileged    = 0x2c1  // Privilege violation
    case kIOReturnBadArgument      = 0x2c2  // Invalid argument
    case kIOReturnLockedRead       = 0x2c3  // Device read locked
    case kIOReturnExclusiveAccess  = 0x2c5  // Exclusive access and device
                                            // already open
    case kIOReturnBadMessageID     = 0x2c6  // Sent/received messages had
                                            // different msg_id
    case kIOReturnUnsupported      = 0x2c7  // Unsupported function
    case kIOReturnVMError          = 0x2c8  // Misc. VM failure
    case kIOReturnInternalError    = 0x2c9  // Internal error
    case kIOReturnIOError          = 0x2ca  // General I/O error
    case kIOReturnQM1Error         = 0x2cb  // ??? - kIOReturn???Error
    case kIOReturnCannotLock       = 0x2cc  // Can't acquire lock
    case kIOReturnNotOpen          = 0x2cd  // Device not open
    case kIOReturnNotReadable      = 0x2ce  // Read not supported
    case kIOReturnNotWritable      = 0x2cf  // Write not supported
    case kIOReturnNotAligned       = 0x2d0  // Alignment error
    case kIOReturnBadMedia         = 0x2d1  // Media Error
    case kIOReturnStillOpen        = 0x2d2  // Device(s) still open
    case kIOReturnRLDError         = 0x2d3  // RLD failure
    case kIOReturnDMAError         = 0x2d4  // DMA failure
    case kIOReturnBusy             = 0x2d5  // Device Busy
    case kIOReturnTimeout          = 0x2d6  // I/O Timeout
    case kIOReturnOffline          = 0x2d7  // Device offline
    case kIOReturnNotReady         = 0x2d8  // Not ready
    case kIOReturnNotAttached      = 0x2d9  // Device not attached
    case kIOReturnNoChannels       = 0x2da  // No DMA channels left
    case kIOReturnNoSpace          = 0x2db  // No space for data
    case kIOReturnQM2Error         = 0x2dc  // ??? - kIOReturn???Error
    case kIOReturnPortExists       = 0x2dd  // Port already exists
    case kIOReturnCannotWire       = 0x2de  // Can't wire down physical
                                            // memory
    case kIOReturnNoInterrupt      = 0x2df  // No interrupt attached
    case kIOReturnNoFrames         = 0x2e0  // No DMA frames enqueued
    case kIOReturnMessageTooLarge  = 0x2e1  // Oversized msg received on
                                            // interrupt port
    case kIOReturnNotPermitted     = 0x2e2  // Not permitted
    case kIOReturnNoPower          = 0x2e3  // No power to device
    case kIOReturnNoMedia          = 0x2e4  // Media not present
    case kIOReturnUnformattedMedia = 0x2e5  // media not formatted
    case kIOReturnUnsupportedMode  = 0x2e6  // No such mode
    case kIOReturnUnderrun         = 0x2e7  // Data underrun
    case kIOReturnOverrun          = 0x2e8  // Data overrun
    case kIOReturnDeviceError      = 0x2e9  // The device is not working
                                            // properly!
    case kIOReturnNoCompletion     = 0x2ea  // A completion routine is
                                            // required
    case kIOReturnAborted          = 0x2eb  // Operation aborted
    case kIOReturnNoBandwidth      = 0x2ec  // Bus bandwidth would be
                                            // exceeded
    case kIOReturnNotResponding    = 0x2ed  // Device not responding
    case kIOReturnIsoTooOld        = 0x2ee  // Isochronous I/O request for
                                            // distant past!
    case kIOReturnIsoTooNew        = 0x2ef  // Isochronous I/O request for
                                            // distant future
    case kIOReturnNotFound         = 0x2f0  // Data was not found
    case kIOReturnInvalid          = 0x1    // Should never be seen
}