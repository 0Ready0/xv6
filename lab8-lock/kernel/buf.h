struct buf {
  int valid;               // 数据是否有效（是否已从磁盘加载）
  int disk;                // 磁盘是否"拥有"缓冲区（是否正在进行 I/O 操作）
  uint dev;                // 设备号（如磁盘0/1）
  uint blockno;            // 磁盘块号（1024字节为单位）
  struct sleeplock lock;   // 睡眠锁（保护缓冲区内容） 
  uint refcnt;             // 引用计数（当前使用者数量）
  struct buf *prev;        // LRU 链表前驱指针
  struct buf *next;        // LRU 链表后继指针
  uchar data[BSIZE];       // 实际缓存数据（BSIZE=1024字节）
  uint timestamp;          // 时间戳
};

