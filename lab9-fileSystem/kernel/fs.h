// On-disk file system format.
// Both the kernel and user programs use this header file.


#define ROOTINO  1   // root i-number
#define BSIZE 1024  // block size

// Disk layout:
// [ boot block | super block | log | inode blocks |
//                                          free bit map | data blocks]
//
// mkfs computes the super block and builds an initial file system. The
// super block describes the disk layout:
struct superblock {
  uint magic;        // Must be FSMAGIC
  uint size;         // Size of file system image (blocks)
  uint nblocks;      // Number of data blocks
  uint ninodes;      // Number of inodes.
  uint nlog;         // Number of log blocks
  uint logstart;     // Block number of first log block
  uint inodestart;   // Block number of first inode block
  uint bmapstart;    // Block number of first free map block
};

#define FSMAGIC 0x10203040

#define NDIRECT 11  // 直接块数量
#define NINDIRECT (BSIZE / sizeof(uint))
#define NDINDIRECT (NINDIRECT * NINDIRECT) // 新增二级间接块容量
#define MAXFILE (NDIRECT + NINDIRECT + NDINDIRECT) // 新增最大文件容量限制

// On-disk inode structure
struct dinode {
  short type;           // 文件类型: 0:未使用, 1: 普通文件, 2: 目录, 3: 设备文件
  short major;          // 主设备号，标识设备类型，文件类型为设备时有效
  short minor;          // 次设备号，标识具体设备，文件类型为设备时有效
  short nlink;          // 硬链接数，表示该inode被多少人使用
  // 如果当前 inode 是文件，表示指向该文件的硬链接数量
  // 如果当前 inode 是目录，每创建一个子目录，父目录的 nlink 加 1，初始值为 2（代表 "." 和 ".."），因为子目录的 ".." 指向父目录
  uint size;            // 表示文件包含的字节数，或者所有目录项（dirent结构体）占用的总字节数
  uint addrs[NDIRECT+2];   // 数据块地址数组：前11个是直接块地址；倒数第二个为一级间接块地址；最后一个为二级块
};

// Inodes per block.
#define IPB           (BSIZE / sizeof(struct dinode))

// Block containing inode i
#define IBLOCK(i, sb)     ((i) / IPB + sb.inodestart)

// Bitmap bits per block
#define BPB           (BSIZE*8)

// Block of free map containing bit for block b
#define BBLOCK(b, sb) ((b)/BPB + sb.bmapstart)

// Directory is a file containing a sequence of dirent structures.
#define DIRSIZ 14

struct dirent {
  ushort inum;          // inode号，2字节
  char name[DIRSIZ];    // 文件名/子目录名，14字节
};

