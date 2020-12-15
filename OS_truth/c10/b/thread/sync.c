#include "sync.h"
#include "list.h"
#include "global.h"
#include "debug.h"
#include "interrupt.h"

/* 初始化信号量 */
void sema_init(struct semaphore* psema, uint8_t value) { // psema 是待初始化的信号量,value是信号量的初值
   psema->value = value;       // 为信号量赋初值
   list_init(&psema->waiters); //初始化信号量的等待队列
}

/* 初始化锁plock */
void lock_init(struct lock* plock) { 
   plock->holder = NULL;
   plock->holder_repeat_nr = 0;
   sema_init(&plock->semaphore, 1);  // 信号量初值为1
}

/* 信号量down操作 */
void sema_down(struct semaphore* psema) {
/* 关中断来保证原子操作 */
   enum intr_status old_status = intr_disable();
   while(psema->value == 0) {	// 若value为0,表示已经被别人持有
      ASSERT(!elem_find(&psema->waiters, &running_thread()->general_tag));
      /* 当前线程不应该已在信号量的waiters队列中 */
      if (elem_find(&psema->waiters, &running_thread()->general_tag)) {
	 PANIC("sema_down: thread blocked has been in waiters_list\n");
      }
/* 若信号量的值等于0,则当前线程把自己加入该锁的等待队列,然后阻塞自己 */
      list_append(&psema->waiters, &running_thread()->general_tag); 
      thread_block(TASK_BLOCKED);    // 阻塞线程,直到被唤醒
   }
/* 若value为1或被唤醒后,会执行下面的代码,也就是获得了锁。*/
   psema->value--;
   ASSERT(psema->value == 0);	    
/* 恢复之前的中断状态 */
   intr_set_status(old_status);
}

/* 信号量的up操作 */
void sema_up(struct semaphore* psema) {
/* 关中断,保证原子操作 */
   enum intr_status old_status = intr_disable();
   ASSERT(psema->value == 0);	    
   if (!list_empty(&psema->waiters)) {// 判断链表飞空,唤醒队首元素
      struct task_struct* thread_blocked = elem2entry(struct task_struct, general_tag, list_pop(&psema->waiters));
      thread_unblock(thread_blocked);
   }
   psema->value++; // 阻塞的线程唤醒了,对应的信号量++,所谓的唤醒不是马上可以运行,而是加到了就绪队列,将来可以参加调度,运行是未来的事情
   ASSERT(psema->value == 1);	    
/* 恢复中断之前的状态 */
   intr_set_status(old_status);
}

/* 获取锁plock */
void lock_acquire(struct lock* plock) { // 接受一个参数,plock是所要获得的锁,函数功能是获取锁plock
/* 排除曾经自己已经持有锁但还未将其释放的情况。*/
   if (plock->holder != running_thread()) { // 线程可能会自己等待自己释放所,因此子啊函数开头判断自己是否已经是该锁的持有人了,如果是自己就把变量holder_repeat_nr++
      sema_down(&plock->semaphore);    // 对信号量P操作,原子操作
      plock->holder = running_thread(); // 成功申领了该锁
      ASSERT(plock->holder_repeat_nr == 0);
      plock->holder_repeat_nr = 1;
   } else {
      plock->holder_repeat_nr++; //就是在这里++的
   }
}

/* 释放锁plock,注:该锁实现的是可重入锁 */
void lock_release(struct lock* plock) { // plock指向释放的锁,函数功能是释放所plock
   ASSERT(plock->holder == running_thread());
   if (plock->holder_repeat_nr > 1) {
      plock->holder_repeat_nr--; // 如果这里发现自己曾经多次申请,则需要--,知道发现自己在也没申请了才不管了
      return;                       //自此锁才真正的释放了
   }
   ASSERT(plock->holder_repeat_nr == 1);

   plock->holder = NULL;	   // 把锁的持有者置空放在V操作(sema_up)之前,因为如果sema_up在前的胡奥,sema_up会吧value放置为1,若老县城甘冈执行完v操作
   plock->holder_repeat_nr = 0;// 还没执行ploc->holder=NULL便被换下处理器,新调度来的进程也可能申请了至二个所,value为1,申请成功,如果这个新线程还没释放所就被换下了处理器,老线程被调度上来,他会继续执行置空操作,这整个就乱了
   sema_up(&plock->semaphore);	   // 信号量的V操作,也是原子操作
}

