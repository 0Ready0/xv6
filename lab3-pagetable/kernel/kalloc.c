// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.
// 文件描述
// - 操作系统的物理内存分配器，负责管理整个系统的物理内存页分配与回收
//   - 按页分配：以4096字节为范围分配物理内存
//   - 内存管理：管理从end(内核结束地址)到PHYSTOP的物理内存
//   - 服务对象：用户进程的内存页、内核栈空间、页表页、管道缓冲区
// - 核心机制：基于  空闲链表  的分配算法
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

void
kinit()
{
  // 函数描述
  // 内存分配器初始化
  initlock(&kmem.lock, "kmem");   // 初始化保护空闲链表的自旋锁
  freerange(end, (void*)PHYSTOP); // 初始化空闲内存池
}

void
freerange(void *pa_start, void *pa_end)
{
  // 函数描述
  // 批量释放内存  - 将连续物理内存区域按页分割并加入空闲链表，确保 页对齐
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;
  // 安全检查：确保页对齐、地址在有效范围
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  // 加入空闲链表
  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  // 函数描述
  // 分配单页内存
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
