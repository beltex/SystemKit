//
// IOReturn.swift
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

import IOKit

//------------------------------------------------------------------------------
// MARK: GLOBAL PUBLIC PROPERTIES
//------------------------------------------------------------------------------


/*
I/O Kit common error codes - as defined in <IOKit/IOReturn.h>

Swift can't import complex macros, thus we have to manually add them here.
Most of these are not relevant to us, but for the sake of completeness. See
"Accessing Hardware From Applications -> Handling Errors" Apple document for
more information.

NOTE: kIOReturnSuccess is the only return code already defined in IOKit module
      for us.

https://developer.apple.com/library/mac/qa/qa1075/_index.html
*/


/// General error
public let kIOReturnError            = iokit_common_err(0x2bc)
/// Can't allocate memory
public let kIOReturnNoMemory         = iokit_common_err(0x2bd)
/// Resource shortage
public let kIOReturnNoResources      = iokit_common_err(0x2be)
/// Error during IPC
public let kIOReturnIPCError         = iokit_common_err(0x2bf)
/// No such device
public let kIOReturnNoDevice         = iokit_common_err(0x2c0)
/// Privilege violation
public let kIOReturnNotPrivileged    = iokit_common_err(0x2c1)
/// Invalid argument
public let kIOReturnBadArgument      = iokit_common_err(0x2c2)
/// Device read locked
public let kIOReturnLockedRead       = iokit_common_err(0x2c3)
/// Exclusive access and device already open
public let kIOReturnExclusiveAccess  = iokit_common_err(0x2c5)
/// Sent/received messages had different msg_id
public let kIOReturnBadMessageID     = iokit_common_err(0x2c6)
/// Unsupported function
public let kIOReturnUnsupported      = iokit_common_err(0x2c7)
/// Misc. VM failure
public let kIOReturnVMError          = iokit_common_err(0x2c8)
/// Internal error
public let kIOReturnInternalError    = iokit_common_err(0x2c9)
/// General I/O error
public let kIOReturnIOError          = iokit_common_err(0x2ca)
/// Can't acquire lock
public let kIOReturnCannotLock       = iokit_common_err(0x2cc)
/// Device not open
public let kIOReturnNotOpen          = iokit_common_err(0x2cd)
/// Read not supported
public let kIOReturnNotReadable      = iokit_common_err(0x2ce)
/// Write not supported
public let kIOReturnNotWritable      = iokit_common_err(0x2cf)
/// Alignment error
public let kIOReturnNotAligned       = iokit_common_err(0x2d0)
/// Media Error
public let kIOReturnBadMedia         = iokit_common_err(0x2d1)
/// Device(s) still open
public let kIOReturnStillOpen        = iokit_common_err(0x2d2)
/// RLD failure
public let kIOReturnRLDError         = iokit_common_err(0x2d3)
/// DMA failure
public let kIOReturnDMAError         = iokit_common_err(0x2d4)
/// Device Busy
public let kIOReturnBusy             = iokit_common_err(0x2d5)
/// I/O Timeout
public let kIOReturnTimeout          = iokit_common_err(0x2d6)
/// Device offline
public let kIOReturnOffline          = iokit_common_err(0x2d7)
/// Not ready
public let kIOReturnNotReady         = iokit_common_err(0x2d8)
/// Device not attached
public let kIOReturnNotAttached      = iokit_common_err(0x2d9)
/// No DMA channels left
public let kIOReturnNoChannels       = iokit_common_err(0x2da)
/// No space for data
public let kIOReturnNoSpace          = iokit_common_err(0x2db)
/// Port already exists
public let kIOReturnPortExists       = iokit_common_err(0x2dd)
/// Can't wire down physical memory
public let kIOReturnCannotWire       = iokit_common_err(0x2de)
/// No interrupt attached
public let kIOReturnNoInterrupt      = iokit_common_err(0x2df)
/// No DMA frames enqueued
public let kIOReturnNoFrames         = iokit_common_err(0x2e0)
/// Oversized msg received on interrupt port
public let kIOReturnMessageTooLarge  = iokit_common_err(0x2e1)
/// Not permitted
public let kIOReturnNotPermitted     = iokit_common_err(0x2e2)
/// No power to device
public let kIOReturnNoPower          = iokit_common_err(0x2e3)
/// Media not present
public let kIOReturnNoMedia          = iokit_common_err(0x2e4)
/// Media not formatted
public let kIOReturnUnformattedMedia = iokit_common_err(0x2e5)
/// No such mode
public let kIOReturnUnsupportedMode  = iokit_common_err(0x2e6)
/// Data underrun
public let kIOReturnUnderrun         = iokit_common_err(0x2e7)
/// Data overrun
public let kIOReturnOverrun          = iokit_common_err(0x2e8)
/// The device is not working properly!
public let kIOReturnDeviceError      = iokit_common_err(0x2e9)
/// A completion routine is required
public let kIOReturnNoCompletion     = iokit_common_err(0x2ea)
/// Operation aborted
public let kIOReturnAborted          = iokit_common_err(0x2eb)
/// Bus bandwidth would be exceeded
public let kIOReturnNoBandwidth      = iokit_common_err(0x2ec)
/// Device not responding
public let kIOReturnNotResponding    = iokit_common_err(0x2ed)
/// Isochronous I/O request for distant past!
public let kIOReturnIsoTooOld        = iokit_common_err(0x2ee)
/// Isochronous I/O request for distant future
public let kIOReturnIsoTooNew        = iokit_common_err(0x2ef)
/// Data was not found
public let kIOReturnNotFound         = iokit_common_err(0x2f0)
/// Should never be seen
public let kIOReturnInvalid          = iokit_common_err(0x1)


//------------------------------------------------------------------------------
// MARK: GLOBAL PRIVATE PROPERTIES
//------------------------------------------------------------------------------


/**
I/O Kit system code is 0x38. First 6 bits of error code. Passed to err_system()
macro as defined in <mach/error.h>.
*/
private let SYS_IOKIT: UInt32 = (0x38 & 0x3f) << 26


/**
I/O Kit subsystem code is 0. Middle 12 bits of error code. Passed to err_sub()
macro as defined in <mach/error.h>.
*/
private let SUB_IOKIT_COMMON: UInt32 = (0 & 0xfff) << 14


//------------------------------------------------------------------------------
// MARK: GLOBAL PRIVATE FUNCTIONS
//------------------------------------------------------------------------------


/**
Based on macro of the same name in <IOKit/IOReturn.h>. Generates the error code.

:param: code The specific I/O Kit error code. Last 14 bits.
:returns: Full 32 bit error code.
*/
private func iokit_common_err(_ code: UInt32) -> kern_return_t {
    // Overflow otherwise
    return Int32(bitPattern: SYS_IOKIT | SUB_IOKIT_COMMON | code)
}

