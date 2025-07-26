//
// File-system system calls.
// Mostly argument checking, since we don't trust
// user code, and calls into file.c and fs.c.
//

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "stat.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
}

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
  int fd;
  struct proc *p = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
}

uint64
sys_dup(void)
{
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
  filedup(f);
  return fd;
}

uint64
sys_read(void)
{
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    return -1;
  return fileread(f, p, n);
}

uint64
sys_write(void)
{
  struct file *f;
  int n;
  uint64 p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    return -1;

  return filewrite(f, p, n);
}

uint64
sys_close(void)
{
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    return -1;
  myproc()->ofile[fd] = 0;
  fileclose(f);
  return 0;
}

uint64
sys_fstat(void)
{
  struct file *f;
  uint64 st; // user pointer to struct stat

  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    return -1;
  return filestat(f, st);
}

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    return -1;

  begin_op();
  if((ip = namei(old)) == 0){
    end_op();
    return -1;
  }

  ilock(ip);
  if(ip->type == T_DIR){
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
  iput(ip);

  end_op();

  return 0;

bad:
  ilock(ip);
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  end_op();
  return -1;
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
}

uint64
sys_unlink(void)
{
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    return -1;

  begin_op();
  if((dp = nameiparent(path, name)) == 0){
    end_op();
    return -1;
  }

  ilock(dp);

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);

  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);

  end_op();

  return 0;

bad:
  iunlockput(dp);
  end_op();
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
  struct inode *ip, *dp;
  char name[DIRSIZ];
  
  // 路径解析
  if((dp = nameiparent(path, name)) == 0)
    return 0;

  ilock(dp);  // 锁定父目录

  // 检查文件是否已经存在
  if((ip = dirlookup(dp, name, 0)) != 0){
    iunlockput(dp);
    ilock(ip);
    // 若需要创建的普通文件已经存在直接返回
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
      return ip;
    iunlockput(ip);
    return 0;
  }

  // 分配新的inode
  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");

  // 初始化inode
  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  // 目录特殊处理
  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
    iupdate(dp);
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  // 链接到父目录
  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}

static struct inode*
symlinkroot(struct inode* ip){
  uint visted[SYMLINKDEPTH];  // 记录已访问的 inode 号（用于环检测）
  char path[MAXPATH];         // 存储从符号链接读取的目标路径

  // 循环解析符号链接（最多 SYMLINKDEPTH 层）
  for(int i = 0; i < SYMLINKDEPTH; i++){
    // 步骤1: 记录当前 inode 号（用于后续环检测）
    visted[i] = ip->inum;

    // 步骤2: 从符号链接读取目标路径
    // 注意：readi 调用前必须持有 ip->lock
    if(readi(ip, 0, (uint64)path, 0, MAXPATH) <= 0)
      goto rootFail;  // 读取失败跳转到错误处理
    
    // 步骤3: 释放当前 inode 锁（避免 namei 死锁）
    iunlockput(ip); // 组合操作：解锁 + 减少引用计数

    // 步骤4: 根据路径查找下一级 inode
    if((ip=namei(path)) == 0)
      return 0;
    
    // 步骤5: 检测符号链接环
    // 检查当前 inode 是否在历史路径中出现过
    for(int tail = i; tail >= 0; tail--){
      if(ip->inum == visted[tail])
        return 0;
    }

    // 步骤6: 锁定新获取的 inode
    ilock(ip);
    // 步骤7: 检查是否到达最终目标
    if(ip->type != T_SYMLINK)  // 找到非符号链接目标
      return ip;               // 持有锁返回给调用者
  }
rootFail:
  iunlockput(ip);
  return 0;
}

uint64
sys_open(void)
{
  char path[MAXPATH];   // 存储文件路径
  int fd, omode;        // fd: 文件描述符, omode: 打开模式标志
  struct file *f;       // 内核文件结构指针
  struct inode *ip;     // 文件对应的inode指针
  int n;                // 临时返回值
  // argstr 从用户态回去第0个参数（文件路径），存入path中，最大长度为MAXPATH
  // argint 获取第一个参数
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    return -1;

  // 开始文件系统事务（确保原子性，常用于日志文件系统）。
  begin_op();

  // 文件创建或路径查找
  if(omode & O_CREATE){   // 文件创建
    ip = create(path, T_FILE, 0, 0);  // 创建新文件
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {    // 文件查找
    if((ip = namei(path)) == 0){  // 查找现有文件路径
      end_op();
      return -1;
    }
    ilock(ip);  // 锁定inode

    // 目录权限检查
    if(ip->type == T_DIR && omode != O_RDONLY){
      iunlockput(ip);
      end_op();
      return -1;
    }
  }

  // 设备文件校验
  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    iunlockput(ip);
    end_op();
    return -1;
  }

  // 符号链接业务
  if(ip->type == T_SYMLINK && (omode & O_NOFOLLOW) == 0){
    // 从ip处追溯
    if((ip = symlinkroot(ip)) == 0){  // 若溯源失败，则在 symlinkroot 中放锁，这是因为代码封装的局限性必须要做出的牺牲
      end_op();
      return -1;
    }
  }

  // 分配文件结构和文件描述符
  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }

  // 初始化文件对象
  if(ip->type == T_DEVICE){ // 设备文件
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {                  // 普通文件/目录
    f->type = FD_INODE;
    f->off = 0;
  }
  f->ip = ip;
  f->readable = !(omode & O_WRONLY);
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);

  // 处理截断标志 (O_TRUNC)
  if((omode & O_TRUNC) && ip->type == T_FILE){
    itrunc(ip);
  }

  iunlock(ip);
  end_op();

  return fd;
}



uint64
sys_mkdir(void)
{
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    end_op();
    return -1;
  }
  iunlockput(ip);
  end_op();
  return 0;
}

uint64
sys_mknod(void)
{
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
  if((argstr(0, path, MAXPATH)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    end_op();
    return -1;
  }
  iunlockput(ip);
  end_op();
  return 0;
}

uint64
sys_chdir(void)
{
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
  
  begin_op();
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
  iput(p->cwd);
  end_op();
  p->cwd = ip;
  return 0;
}

uint64
sys_exec(void)
{
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv)){
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
      goto bad;
    }
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
      goto bad;
  }

  int ret = exec(path, argv);

  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    kfree(argv[i]);
  return -1;
}

uint64
sys_pipe(void)
{
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();

  if(argaddr(0, &fdarray) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    p->ofile[fd0] = 0;
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
}

uint64
sys_symlink(void)
{
  struct inode *ip;        // 符号链接文件的 inode 指针
  char target[MAXPATH];    // 符号链接指向的目标路径
  char path[MAXPATH];      // 符号链接文件自身的路径

  /* 步骤1: 从用户空间获取参数 */
  // argstr(0): 获取第一个参数(target), argstr(1): 获取第二个参数(path)
  if(argstr(0, target, MAXPATH) < 0 || argstr(1, path, MAXPATH) < 0)
    return -1;  // 参数无效或路径过长

  /* 步骤2: 开始文件系统事务 (日志系统) */
  begin_op();  // 确保操作的原子性（要么全完成，要么全不完成）

  /* 步骤3: 在文件系统中创建符号链接节点 */
  // create 参数说明:
  //   path: 符号链接的路径
  //   T_SYMLINK: 指定为符号链接类型
  //   0,0: 主/次设备号（符号链接不需要设备号）
  //
  // 关键：create 返回时持有 ip->lock（防止并发修改）
  if((ip = create(path, T_SYMLINK, 0, 0)) == 0) {
    // 创建失败（路径已存在/磁盘空间不足等）
    end_op();  // 结束事务（回滚未完成操作）
    return -1;
  }

  /* 步骤4: 将目标路径写入符号链接文件 */
  // writei 参数说明:
  //   ip: 目标 inode
  //   0: 设备号（忽略）
  //   (uint64)target: 源数据地址（内核空间）
  //   0: 写入偏移量（从文件开头）
  //   strlen(target): 写入字节数
  //
  // 注意：此时仍持有 ip->lock（create 未释放），满足 writei 的锁要求
  if(writei(ip, 0, (uint64)target, 0, strlen(target)) < 0) {
    // 写入失败（磁盘错误/超出块大小等）
    iunlockput(ip);  // 关键：释放锁 + 减少引用计数（ip->lock 由 create 获取）
    end_op();        // 结束事务
    return -1;
  }

  /* 步骤5: 释放资源（成功路径）*/
  iunlockput(ip);  // 组合操作:
                   //   iunlock(ip): 释放 inode 锁
                   //   iput(ip): 减少引用计数（若为0则释放 inode）
  
  end_op();  // 提交文件系统事务（确保操作持久化）
  return 0;  // 成功返回
}