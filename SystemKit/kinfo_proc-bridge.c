//
// kinfo_proc-bridge.c
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014  beltex <https://github.com/beltex>
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


int kinfo_for_pid(pid_t pid, kinfo_proc_systemkit *kinfo_sk)
{
    struct kinfo_proc kinfo;
    size_t len = sizeof(struct kinfo_proc);

    int mib[]    = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
    u_int miblen = 4;
    
    int res = sysctl(mib, miblen, &kinfo, &len, NULL, 0);
    if (res != 0) {
        printf("ERROR");
        return -1;
    }
    
    // TODO: Are there any other stats we want from this struct? top only takes
    //       these, and gets everything else from the lower level Mach task.
    
    kinfo_sk->__p_starttime = kinfo.kp_proc.p_un.__p_starttime;
    kinfo_sk->p_stat        = kinfo.kp_proc.p_stat;
    kinfo_sk->p_flag        = kinfo.kp_proc.p_flag;
    
    printf("NAME: %s\n", kinfo.kp_proc.p_comm);
    //kinfo_sk->p_comm        = kinfo.kp_proc.p_comm;
    kinfo_sk->e_pgid        = kinfo.kp_eproc.e_pgid;
    kinfo_sk->e_ppid        = kinfo.kp_eproc.e_ppid;
    kinfo_sk->e_ucred       = kinfo.kp_eproc.e_ucred;
    
    return 0;
}
