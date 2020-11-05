[bits 32]
%define ERROR_CODE nop		 ; 若在相关的异常中cpu已经自动压入了错误码,为保持栈中格式统一,这里不做操作.
%define ZERO push 0		 ; 若在相关的异常中cpu没有压入错误码,为了统一栈中格式,就手工压入一个0

extern put_str			 ;声明外部函数

section .data
intr_str db "interrupt occur!", 0xa, 0
global intr_entry_table
intr_entry_table:

%macro VECTOR 2     ; 宏定义处理程序的地方,在这里定义了vector宏,接受2个参数
section .text
intr%1entry:		 ; 每个中断处理程序都要压入中断向量号,所以一个中断类型一个中断处理程序，自己知道自己的中断向量号是多少
   %2                ; 定义的中断处理程序,
   push intr_str     ; 在中断程序中打印字符串"interrupt occur"
   call put_str
   add esp,4			 ; 跳过参数

   ; 如果是从片上进入的中断,除了往从片上发送EOI外,还要往主片上发送EOI 
   mov al,0x20                   ; 中断结束命令EOI
   out 0xa0,al                   ; 向从片发送
   out 0x20,al                   ; 向主片发送

   add esp,4			 ; 跨过error_code
   iret				 ; 从中断返回,32位下等同指令iretd

section .data            ; 在kernel.S中定义了一个数组,数组名为intr_entry_table,他在第10行定义,在第九行global语句到处全局符号
   dd    intr%1entry	 ; 存储各个中断入口程序的地址，形成intr_entry_table数组,在28和29定义数据段,因为32位下的地址是4字节,所以我在29行用伪指令dd来定义数组元素的宽度
%endmacro

VECTOR 0x00,ZERO
VECTOR 0x01,ZERO
VECTOR 0x02,ZERO
VECTOR 0x03,ZERO 
VECTOR 0x04,ZERO
VECTOR 0x05,ZERO
VECTOR 0x06,ZERO
VECTOR 0x07,ZERO 
VECTOR 0x08,ERROR_CODE
VECTOR 0x09,ZERO
VECTOR 0x0a,ERROR_CODE
VECTOR 0x0b,ERROR_CODE 
VECTOR 0x0c,ZERO
VECTOR 0x0d,ERROR_CODE
VECTOR 0x0e,ERROR_CODE
VECTOR 0x0f,ZERO 
VECTOR 0x10,ZERO
VECTOR 0x11,ERROR_CODE
VECTOR 0x12,ZERO
VECTOR 0x13,ZERO 
VECTOR 0x14,ZERO
VECTOR 0x15,ZERO
VECTOR 0x16,ZERO
VECTOR 0x17,ZERO 
VECTOR 0x18,ERROR_CODE
VECTOR 0x19,ZERO
VECTOR 0x1a,ERROR_CODE
VECTOR 0x1b,ERROR_CODE 
VECTOR 0x1c,ZERO
VECTOR 0x1d,ERROR_CODE
VECTOR 0x1e,ERROR_CODE              ; 调用宏cector的地方
VECTOR 0x1f,ZERO                    ; 第一个参数0x1f是中断向量号,第二个参数是zero,他是一个宏,也就是说zero的值是push 0,把0压入栈的操作
VECTOR 0x20,ZERO
