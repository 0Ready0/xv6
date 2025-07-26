struct file {
  enum { FD_NONE, FD_PIPE, FD_INODE, FD_DEVICE } type;
  int ref; // reference count
  char readable;
  char writable;
  struct pipe *pipe; // FD_PIPE
  struct inode *ip;  // FD_INODE and FD_DEVICE
  uint off;          // FD_INODE
  short major;       // FD_DEVICE
};

#define major(dev)  ((dev) >> 16 & 0xFFFF)
#define minor(dev)  ((dev) & 0xFFFF)
#define	mkdev(m,n)  ((uint)((m)<<16| (n)))

// in-memory copy of an inode
struct inode {
  uint dev;           // 设备号：inode所在的设备
  uint inum;          // inode编号：在inode表中的索引
  int ref;            // 引用计数：有多少进程在使用这个inode
  struct sleeplock lock; // 睡眠锁：保护inode的内容
  int valid;          // 有效标志：inode是否从磁盘加载

  short type;         // copy of disk inode, 表名当前inode是文件还是目录
  short major;        // 主设备号，标识设备类型，文件类型为设备时有效
  short minor;        // 次设备号，标识具体设备，文件类型为设备时有效
  short nlink;        // link计数器，记录有多少个文件名指向了当前的inode
  uint size;          // 表明了文件数据有多少字节
  uint addrs[NDIRECT+2];
};

// map major device number to device functions.
struct devsw {
  int (*read)(int, uint64, int);
  int (*write)(int, uint64, int);
};

extern struct devsw devsw[];

#define CONSOLE 1
