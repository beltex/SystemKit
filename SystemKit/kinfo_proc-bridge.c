

#include "kinfo_proc-bridge.h"


int kinfo_for_pid(pid_t pid, kinfo_proc_systemkit *kinfo_sk)
{
    struct kinfo_proc kinfo;
    size_t miblen = 4, len;
    int mib[miblen];
    int res;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = pid;
    len = sizeof(struct kinfo_proc);
    res = sysctl(mib, 4, &kinfo, &len, NULL, 0);
    if (res != 0) {
        printf("ERROR");
        return -1;
    }
    
    kinfo_sk->__p_starttime = kinfo.kp_proc.p_un.__p_starttime;
    kinfo_sk->p_stat        = kinfo.kp_proc.p_stat;
    kinfo_sk->p_flag        = kinfo.kp_proc.p_flag;
    //kinfo_sk->p_comm        = kinfo.kp_proc.p_comm;
    kinfo_sk->e_pgid        = kinfo.kp_eproc.e_pgid;
    kinfo_sk->e_ppid        = kinfo.kp_eproc.e_ppid;
    kinfo_sk->e_ucred       = kinfo.kp_eproc.e_ucred;
    
    return 0;
}