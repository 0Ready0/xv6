// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

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
} kmem[NPROC];  // 每个CPU都拥有自己的可用的内存链表

void
kinit()
{
  // initlock(&kmem.lock, "kmem");
  for(int i = 0 ; i < NPROC; i++){
    initlock(&kmem[i].lock, "kmem");
  }
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
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
  int id = cpuid();

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  // 原先的逻辑，加锁，把空闲页加到链表的头部，再释放锁
  // acquire(&kmem.lock);
  // r->next = kmem.freelist;
  // kmem.freelist = r;
  // release(&kmem.lock);
  
  // 修改为，把每个空闲页加入到正在执行的CPU链表中
  acquire(&kmem[id].lock);
  r->next = kmem[id].freelist;
  kmem[id].freelist = r;
  release(&kmem[id].lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r = 0;
  
  // acquire(&kmem.lock);
  // r = kmem.freelist;
  // if(r)
  //   kmem.freelist = r->next;
  // release(&kmem.lock);

  // 修改为，优先从当前CPU中获取一个空闲页，如果失败，从当前 CPU 右手边开始遍历，直到找到一页或者都没有可用内存
  for(int i = 0, curid = cpuid(); i < NPROC && !r; i++, curid++){
    if(curid==NPROC) curid = 0; // 环形遍历
    acquire(&kmem[curid].lock);
    r = kmem[curid].freelist;
    if(r){
      kmem[curid].freelist = r->next;
    }
    release(&kmem[curid].lock);
  }




  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
