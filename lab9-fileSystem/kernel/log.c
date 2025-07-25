#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "buf.h"

// Simple logging that allows concurrent FS system calls.
//
// A log transaction contains the updates of multiple FS system
// calls. The logging system only commits when there are
// no FS system calls active. Thus there is never
// any reasoning required about whether a commit might
// write an uncommitted system call's updates to disk.
//
// A system call should call begin_op()/end_op() to mark
// its start and end. Usually begin_op() just increments
// the count of in-progress FS system calls and returns.
// But if it thinks the log is close to running out, it
// sleeps until the last outstanding end_op() commits.
//
// The log is a physical re-do log containing disk blocks.
// The on-disk log format:
//   header block, containing block #s for block A, B, C, ...
//   block A
//   block B
//   block C
//   ...
// Log appends are synchronous.

// Contents of the header block, used for both the on-disk header block
// and to keep track in memory of logged block# before commit.
struct logheader {
  int n;
  int block[LOGSIZE];
};

struct log {
  struct spinlock lock;
  int start;
  int size;
  int outstanding; // how many FS sys calls are executing.
  int committing;  // in commit(), please wait.
  int dev;
  struct logheader lh;
};
struct log log;

static void recover_from_log(void);
static void commit();

void
initlog(int dev, struct superblock *sb)
{
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  initlock(&log.lock, "log");
  log.start = sb->logstart;
  log.size = sb->nlog;
  log.dev = dev;
  recover_from_log();
}

// Copy committed blocks from log to their home location
static void
install_trans(int recovering)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    if(recovering == 0)
      bunpin(dbuf);
    brelse(lbuf);
    brelse(dbuf);
  }
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
}

// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
  brelse(buf);
}

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
  log.lh.n = 0;
  write_head(); // clear the log
}

// begin_op() 和 end_op()的作用
// 对一组磁盘操作提供原子性支持，即“要么全部完成，要么全部不做”，以防止系统崩溃后留下“半写入”的数据。

// 开始一次文件系统操作前必须调用此函数
// 确保日志有足够空间、安全启动操作
void
begin_op(void)
{
  // 加锁，保证对日志系统的互斥访问
  acquire(&log.lock);
  while(1){
    // 如果日志系统正在提交(commit)中，则等待提交完成
    if(log.committing){
      sleep(&log, &log.lock); // 释放锁并睡眠，等待唤醒
    // 如果当前日志空间不足以容纳新的操作，则等待
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // 计算：当前日志中已使用块数 + 本次操作所需的最大块数 > 总日志大小
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock); // 等待其他操作释放空间
    } else {
      // 日志空间足够，记录一个正在进行的操作
      log.outstanding += 1;
      release(&log.lock); // 解锁，允许其他线程访问日志系统
      break;
    }
  }
}

// 每个文件系统调用结束时必须调用该函数
// 如果这是最后一个正在进行的操作，则执行提交
void
end_op(void)
{
  int do_commit = 0;          // 标志位：是否需要执行提交

  acquire(&log.lock);         // 加锁访问日志状态
  log.outstanding -= 1;       // 当前操作结束，减少未完成操作数

  // 检查是否有并发的提交，正常情况下不应该出现
  if(log.committing)
    panic("log.committing");

  // 如果没有其他未完成的操作了，准备提交
  if(log.outstanding == 0){
    do_commit = 1;          // 标记需要提交
    log.committing = 1;     // 设置提交状态，防止其他操作插入
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    // 如果还有其他操作进行中，可能有操作正在等待空间
    wakeup(&log);    // 唤醒等待 begin_op 中睡眠的线程
  }
  release(&log.lock);

  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    // 提交操作不能在持锁状态下执行（commit中可能会sleep）
    commit();
    acquire(&log.lock);      // 提交完成后重新加锁
    log.committing = 0;      // 清除提交标记
    wakeup(&log);            // 唤醒可能在等待提交完成的线程
    release(&log.lock);      // 释放锁
  }
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}

static void
commit()
{
  if (log.lh.n > 0) {
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    install_trans(0); // Now install writes to home locations
    log.lh.n = 0;
    write_head();    // Erase the transaction from the log
  }
}

// Caller has modified b->data and is done with the buffer.
// Record the block number and pin in the cache by increasing refcnt.
// commit()/write_log() will do the disk write.
//
// log_write() replaces bwrite(); a typical use is:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
  // 函数描述
  // 在事务（transaction）期间记录缓冲区块的修改。它不会立刻把块写入磁盘，而是把块号记录在日志（log）中。
  // 之后由 commit() 把所有记录的块一次性写入磁盘，保证原子性和持久性。
  int i;

  // 如果日志条目已满，说明一次事务写入的数据太多，直接崩溃报错
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  // 如果没有处于事务之中（即没有调用 begin_op），这是不允许的
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  // 加锁，保护 log.lh 的并发访问
  acquire(&log.lock);

  // 检查该块是否已经在日志中记录过（log absorption：避免重复写入）
  for (i = 0; i < log.lh.n; i++) {
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  // 将块号加入日志头（log header）的 block 数组中
  log.lh.block[i] = b->blockno;
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);        // 标记该缓冲区在提交前不能被释放或写回
    log.lh.n++;     // 增加日志记录数
  }
  release(&log.lock);
}

