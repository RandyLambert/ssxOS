;主引导程序 
;
;LOADER_BASE_ADDR equ 0xA000 
;LOADER_START_SECTOR equ 0x2
;------------------------------------------------------------
SECTION MBR vstart=0x7c00         
   mov ax,cs      
   mov ds,ax
   mov es,ax
   mov ss,ax
   mov fs,ax
   mov sp,0x7c00
   mov ax,0xb800        ;往gs寄存器中存入段地址
   mov gs,ax            ;显存段地址放到那个寄存器中都没关系，对于访问的数据，如果不用ds做段基址寄存器，就要在寻址中显示的指明要用那个段寄存器的值做段基址

; 清屏
;利用0x06号功能，上卷全部行，则可清屏。
; -----------------------------------------------------------
;INT 0x10   功能号:0x06	   功能描述:上卷窗口
;------------------------------------------------------
;输入：
;AH 功能号= 0x06
;AL = 上卷的行数(如果为0,表示全部)
;BH = 上卷行属性
;(CL,CH) = 窗口左上角的(X,Y)位置
;(DL,DH) = 窗口右下角的(X,Y)位置
;无返回值：
   mov     ax, 0600h
   mov     bx, 0700h
   mov     cx, 0               ; 左上角: (0, 0)
   mov     dx, 184fh	       ; 右下角: (80,25),
			       ; 因为VGA文本模式中，一行只能容纳80个字符,共25行。
			       ; 下标从0开始，所以0x18=24,0x4f=79
   int     10h                 ; int 10h

   ; 输出背景色绿色，前景色红色，并且跳动的字符串"1 MBR"
   mov byte [gs:0x00],'1'      ;执行mov操作都是往显存中写字符，这个是以gs为数据段基地址
   mov byte [gs:0x01],0xA4     ; A表示绿色背景闪烁，4表示前景色为红色,为字符添加颜色

   mov byte [gs:0x02],' '
   mov byte [gs:0x03],0xA4

   mov byte [gs:0x04],'M'
   mov byte [gs:0x05],0xA4   

   mov byte [gs:0x06],'B'
   mov byte [gs:0x07],0xA4

   mov byte [gs:0x08],'R'
   mov byte [gs:0x09],0xA4

   jmp $		       ; 通过死循环使程序悬停在此

   times 510-($-$$) db 0
   db 0x55,0xaa
