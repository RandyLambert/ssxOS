[bits 32]
section .text
global switch_to ;有两个参数 next 和 cur,下面有代码去取值,如果 next 线程之前尚未执行过,马上开始第一次执行
switch_to:      ;此时栈顶的值是函数 kernel_thread 的地址,这是由 thread_create 函数设置的,执行 ret 指令后处理器会去执行函数kernel_thread
   ;栈中此处是返回地址	       
   push esi ;遵守abi原则
   push edi
   push ebx
   push ebp

   mov eax, [esp + 20]		 ; 得到栈中的参数cur, cur = [esp+20],是获取栈中 cur 的值
   mov [eax], esp                ; 保存栈顶指针esp. task_struct的self_kstack字段,
				 ; self_kstack在task_struct中的偏移为0,
				 ; 所以直接往thread开头处存4字节便可。
;------------------  以上是备份当前线程的环境，下面是恢复下一个线程的环境  ----------------
   mov eax, [esp + 24]		 ; 得到栈中的参数next, next = [esp+24]
   mov esp, [eax]		 ; pcb的第一个成员是self_kstack成员,用来记录0级栈顶指针,
				 ; 用来上cpu时恢复0级栈,0级栈中保存了进程或线程所有信息,包括3级栈指针
   pop ebp      ; 第19-22行按照寄存器保存的逆顺序
   pop ebx
   pop edi
   pop esi
   ret				 ; 返回到上面switch_to下面的那句注释的返回地址,
				 ; 未由中断进入,第一次执行时会返回到kernel_thread
