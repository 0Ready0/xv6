#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_trace(void)
{

  int mask;
  // 获取当前执行的系统调用的System call numbers
  if(argint(0, &mask) < 0)  // argint(): 从当前进程的系统调用参数中获取整数参数
    return -1;              //    -> 系统调用参数通过寄存器传递 -> argint 从当前进程的陷阱帧（trapframe）中读取指定位置的参数（如第 n 个参数）
  struct proc *p = myproc();  // myproc(): 获取指向当前进程的 struct proc指针
  p->trace_mask = mask;
  return 0;
}

uint64 
sys_sysinfo(void){
  
  // 从用户态读入一个指针作为存放sysinfo结构的缓冲区
  uint64 addr;
  if(argaddr(0, &addr) < 0){   // argaddr() : 从系统调用参数中获取一个地址
    return -1;
  }

  struct sysinfo sinfo;
  sinfo.freemem = count_free_mem();
  sinfo.nproc = count_process();

  // 使用copyout，结合当前进程的页表，获得进程传进来的指针（逻辑指针）对应的物理地址
  // 然后将 &sinfo 中的数据复制到该指针所知位置，供用户进程使用
  if(copyout(myproc()->pagetable, addr, (char*)&sinfo, sizeof(sinfo)) < 0){ // copyout() : 将数据从内核空间安全复制到用户空间。
    return -1;
  }
  return 0;
  
}