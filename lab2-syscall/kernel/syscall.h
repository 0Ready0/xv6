// 文件描述
// syscall文件 在 xv6 操作系统中扮演着系统调用的调度中心角色
// 它是连接用户空间请求和内核实现的关键枢纽

// 系统调用号定义	#define SYS_fork 1 等宏定义	    用户态与内核态的统一标识符
// 系统调用表声明	extern uint64 sys_fork(void)	建立调用号与实现函数的映射关系
// 参数传递规范	    通过寄存器约定	                实现用户/内核空间数据交换
// 错误处理接口	    struct proc 中的错误状态	    向用户空间返回错误信息

// System call numbers
#define SYS_fork    1
#define SYS_exit    2
#define SYS_wait    3
#define SYS_pipe    4
#define SYS_read    5
#define SYS_kill    6
#define SYS_exec    7
#define SYS_fstat   8
#define SYS_chdir   9
#define SYS_dup    10
#define SYS_getpid 11
#define SYS_sbrk   12
#define SYS_sleep  13
#define SYS_uptime 14
#define SYS_open   15
#define SYS_write  16
#define SYS_mknod  17
#define SYS_unlink 18
#define SYS_link   19
#define SYS_mkdir  20
#define SYS_close  21
#define SYS_trace  22