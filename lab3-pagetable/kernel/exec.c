#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);
void vmprint(pagetable_t pagetable, uint depth);

int
exec(char *path, char **argv)
{
  // 函数描述
  // 用户程序加载器 - 把当前进程的地址空间清空，然后加载一个新的 ELF 可执行文件，初始化堆栈，跳到新的入口执行。

  // 打开 ELF 文件 ➜ 检查 magic number ➜ 读取 program header ➜ 遍历每个 segment ➜
  // 判断是否是可加载段 ➜ 分配内存页（uvmalloc） ➜ 加载文件内容到内存（loadseg） ➜
  // 完成所有段加载 ➜ 释放 inode ➜
  //         ↓
  // 创建新页表（proc_pagetable） ➜ 分配用户栈（2页，含栈溢出保护） ➜ 栈指针向下移动 ➜
  // 逐个拷贝参数字符串 ➜ 记录参数地址 ➜ 构造 argv 指针数组 ➜ 拷贝 argv[] 到栈上 ➜
  //         ↓
  // 设置 trapframe ➜ 指定程序入口（epc） ➜ 设置用户栈顶指针（sp） ➜ 设置 argv 地址（a1） ➜
  //         ↓
  // 保存程序名（调试用） ➜ 切换到新页表 ➜ 更新进程大小 sz ➜ 释放旧页表内存 ➜
  //         ↓
  // （可选）打印页表信息（pid == 1） ➜ 返回 argc（将进入 a0） ➜ 从内核态返回 ➜
  //         ↓
  // 执行 `sret` ➜ 跳转到新程序入口 ➜ 运行用户态程序开始执行

  char *s, *last;
  int i, off;
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();

  begin_op();

  if((ip = namei(path)) == 0){    // 根据路径查找文件
    end_op();
    return -1;
  }
  ilock(ip);                      // 加锁

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf)) // 读取ELF header
    goto bad;
  if(elf.magic != ELF_MAGIC)    // 检查是否是 ELF 文件
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)    // 为当前进程创建新页表
    goto bad;

  // Load program into memory.  加载 ELF 程序段（代码段 / 数据段）
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))   // 读取每个程序段
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)  // 为该段分配虚拟地址空间
      goto bad;
    if(sz1 >= PLIC) // 添加检测，防止程序大小超过 PLIC
      goto bad;
    sz = sz1;
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)  // 把文件中的代码/数据拷进内存
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;

  p = myproc();
  uint64 oldsz = p->sz;

  // Allocate two pages at the next page boundary.
  // Use the second as the user stack.
  // 分配用户栈
  sz = PGROUNDUP(sz);   // 向上对齐
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)    // 分配两页作为栈空间
    goto bad;
  sz = sz1;
  uvmclear(pagetable, sz-2*PGSIZE);   // 把底下一页标为非法页（栈溢出检测）
  sp = sz;
  stackbase = sp - PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  //  压入参数字符串和 argv 数组
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    if(sp < stackbase)
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[argc] = sp;
  }
  ustack[argc] = 0;

  // push the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
  sp -= sp % 16;
  if(sp < stackbase)
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    goto bad;

  // arguments to user main(argc, argv)
  // argc is returned via the system call return
  // value, which goes in a0.
  p->trapframe->a1 = sp;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(p->name, last, sizeof(p->name));
  
  // 清除内核页表中对程序内存的旧映射，重建建立新映射
  uvmunmap(p->kernelpgtbl, 0, PGROUNDUP(oldsz)/PGSIZE, 0);
  kvmcopymappings(pagetable, p->kernelpgtbl, 0, sz);
  
  // Commit to the user image.
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;
  p->trapframe->epc = elf.entry;  // initial program counter = main
  p->trapframe->sp = sp; // initial stack pointer
  proc_freepagetable(oldpagetable, oldsz);

  if(p->pid == 1)   // 打印页表信息
    vmprint(p->pagetable, 0);

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  return -1;
}

// Load a program segment into pagetable at virtual address va.
// va must be page-aligned
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
static int
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
      return -1;
  }
  
  return 0;
}
