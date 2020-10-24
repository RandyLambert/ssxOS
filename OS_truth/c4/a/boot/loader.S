   %include "boot.inc"                      ;头文件
   section loader vstart=LOADER_BASE_ADDR   
   LOADER_STACK_TOP equ LOADER_BASE_ADDR    ;load——stack——top是用于loader在保护模式下定站，等于base——addr，这是在实模式下的栈指针地址，只不过为了进入保护模式后，咱们得为保护模式下的esp初始化，所以用了相同内存地址作为栈顶
   jmp loader_start					; 此处的物理地址是:
   
;构建gdt及其内部的描述符,6-17行在构建全局描述符表，并直接在里面填充段描述符，gdt的其实地址是彪啊还gdt_base所在的地址
   GDT_BASE:   dd    0x00000000 ;因为gdt中的第0个描述符不可用，所以在7-8行直接将段描述符的高4个字节和低四个字节分别定义为0
	       dd    0x00000000     ;

   CODE_DESC:  dd    0x0000FFFF     ;段描述符的低4个字节比较容易定义，其中低2个字节是段界限的0-15位，高两个字节是段基质的0-15位，这块是段地址的低4个字节
	       dd    DESC_CODE_HIGH4    ;定义代码段描述符的高4个字节

   DATA_STACK_DESC:  dd    0x0000FFFF ;是数据段和栈段的段描述符，这里的数据段和栈段共同使用1个段描述符
		     dd    DESC_DATA_HIGH4

   VIDEO_DESC: dd    0x80000007	       ;limit=(0xbffff-0xb8000)/4k=0x7，显存段描述符，内存地址0xc0000 显示适配器bios所在区域，为了方便显存操作，显存段不采用平坦模式
	       dd    DESC_VIDEO_HIGH4  ; 此时dpl已改为0

   GDT_SIZE   equ   $ - GDT_BASE    ;通过地址差来获得gdt的大小，进而用gdt的大小－1得到段界限
   GDT_LIMIT   equ   GDT_SIZE -	1 
   times 60 dq 0					 ; 此处预留60个描述符的slot，纯粹是未来之后给gdt中添加其他描述符提前保留空间而已，以后还要为gdt中继续加入终端描述符表和任务状态段tss描述符，此条指令就是提前预留60个描述符空位，times是nasm的伪指令
   SELECTOR_CODE equ (0x0001<<3) + TI_GDT + RPL0         ; 相当于(CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0
   SELECTOR_DATA equ (0x0002<<3) + TI_GDT + RPL0	 ; 同上，构建代码段，数据段，显存段的选择子，，目前数据段和栈段的选择子是同一个
   SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0	 ; 同上 

   ;以下是定义gdt的指针，前2字节是gdt界限，后4字节是gdt起始地址

   gdt_ptr  dw  GDT_LIMIT ;定义全局描述符表gdt的指针，该指针是lgdt加载gdt到gdtr寄存器时用的
	    dd  GDT_BASE      ;lgdt48位内存数据的钱16位是gdt以字节为单位的界限这，也就是gdt大小-1，后32位是gdt的起始地址
   loadermsg db '2 loader in real.' ;定义一个字符串，用来“显示”一会要进入的保护模式

   loader_start:

;------------------------------------------------------------
;INT 0x10    功能号:0x13    功能描述:打印字符串
;------------------------------------------------------------
;输入:
;AH 子功能号=13H
;BH = 页码
;BL = 属性(若AL=00H或01H)
;CX＝字符串长度
;(DH、DL)＝坐标(行、列)
;ES:BP＝字符串地址 
;AL＝显示输出方式
;   0——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置不变
;   1——字符串中只含显示字符，其显示属性在BL中。显示后，光标位置改变
;   2——字符串中含显示字符和显示属性。显示后，光标位置不变
;   3——字符串中含显示字符和显示属性。显示后，光标位置改变
;无返回值
   mov	 sp, LOADER_BASE_ADDR
   mov	 bp, loadermsg           ; ES:BP = 字符串地址
   mov	 cx, 17			 ; CX = 字符串长度，调用的bios调用，利用bios中断中的int 0x10打印字符串的功能，cx寄存器是字符串的长度，这是int 0x10的参数。“2 loader in real.”是17个字符
   mov	 ax, 0x1301		 ; AH = 13,  AL = 01h
   mov	 bx, 0x001f		 ; 页号为0(BH = 0) 蓝底粉红字(BL = 1fh)
   mov	 dx, 0x1800		 ; 行数dh是0x18 列数dl是0x00，这也是int 0x10的参数，因为该文本模式下的行数25行，0x18的十进制是24，所以会打印到最后一行
   int	 0x10                    ; 10h 号中断

;----------------------------------------   准备进入保护模式   ------------------------------------------
									;1 打开A20
									;2 加载gdt
									;3 将cr0的pe位置1


   ;-----------------  打开A20  ----------------
   in al,0x92
   or al,0000_0010B
   out 0x92,al

   ;-----------------  加载GDT  ----------------
   lgdt [gdt_ptr]               ;gdt——ptr是前面介绍过的gdt地址指针变量，gdt——ptr是一个地址，所以需要在此处取地址，值才是lgdt


   ;-----------------  cr0第0位置1  ----------------
   mov eax, cr0             ;进入保护模式的第三步，将pe值置为1，从此进入了保护模式的大门
   or eax, 0x00000001       ;相当于保护模式的开关
   mov cr0, eax             ;使用bochs的creg来查看控制寄存器的命令

   ;jmp dword SELECTOR_CODE:p_mode_start	     ; 刷新流水线，避免分支预测的影响,这种cpu优化策略，最怕jmp跳转，
   jmp  SELECTOR_CODE:p_mode_start	     ; 刷新流水线，避免分支预测的影响,这种cpu优化策略，最怕jmp跳转，
					     ; 这将导致之前做的预测失效，从而起到了刷新的作用。

[bits 32]
p_mode_start:                            ; 选择子出事化为各段寄存器
   mov ax, SELECTOR_DATA                 
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov esp,LOADER_STACK_TOP
   mov ax, SELECTOR_VIDEO
   mov gs, ax                            ;往显存第80个字符的位置写入字符p

   mov byte [gs:160], 'P'                ;p是在保护模式中打印的，2loader是子啊实模式打印的

   jmp $
