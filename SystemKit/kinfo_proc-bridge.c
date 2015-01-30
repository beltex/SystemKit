//
// kinfo_proc-bridge.c
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

#include "kinfo_proc-bridge.h"

/**
Get kinfo_proc for given process via PID. See link for why we need to do this in
C and not Swift, currently.

https://github.com/beltex/SystemKit/issues/12
*/
int kinfo_for_pid(pid_t pid, kinfo_proc_systemkit *kinfo_sk)
{
    struct kinfo_proc kinfo;
    size_t len = sizeof(struct kinfo_proc);

    int mib[]    = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
    u_int miblen = 4;
    
    int res = sysctl(mib, miblen, &kinfo, &len, NULL, 0);
    if (res != 0) {
        // TODO: DEBUG macro here
        printf("ERROR");
        return -1;
    }
    
    // TODO: Are there any other stats we want from this struct? top only takes
    //       these, and gets everything else from the lower level Mach task.
    
    kinfo_sk->p_stat = kinfo.kp_proc.p_stat;
    kinfo_sk->e_pgid = kinfo.kp_eproc.e_pgid;
    kinfo_sk->e_ppid = kinfo.kp_eproc.e_ppid;
    kinfo_sk->uid    = kinfo.kp_eproc.e_ucred.cr_uid;
    
    for (int i = 0; i < MAXCOMLEN + 1; i++) {
        kinfo_sk->p_comm[i] = kinfo.kp_proc.p_comm[i];
    }
    
    return 0;
}
