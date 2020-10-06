         ;代码清单7-1
         ;文件名：c07_mbr.asm
         ;文件说明：硬盘主引导扇区代码
         ;创建日期：2011-4-13 18:02
         
         jmp near start         ;跳过没有指令的数据段
	
 message db '1+2+3+...+100='    ;数据段
        
 start:
         mov ax,0x7c0           ;设置数据段的段基地址 
         mov ds,ax              ;初始化数据段寄存器DS

         mov ax,0xb800          ;设置附加段基址到显示缓冲区
         mov es,ax              ;初始化附加段寄存器ES

         ;以下显示字符串 
         mov si,message          ;将索引寄存器SI指向数据寄存段DS首地址，即标号“message”所代表的汇编地址
         mov di,0                ;在用另一个索引寄存器DI指向ES段内的偏移地址0处，ES是指向0xb800段
         mov cx,start-message    ;编译阶段计算一个循环计数，该循环次数等于字符串的长度
     @g:
         mov al,[si]
         mov [es:di],al
         inc di
         mov byte [es:di],0x07
         inc di
         inc si
         loop @g                 ;数据循环依赖loop，loop指令的工作又依赖与CX寄存器

         ;以下计算1到100的和 
         xor ax,ax
         mov cx,1
     @f:
         add ax,cx
         inc cx
         cmp cx,100
         jle @f

         ;以下计算累加和的每个数位 
         xor cx,cx              ;设置堆栈段的段基地址
         mov ss,cx
         mov sp,cx

         mov bx,10
         xor cx,cx
     @d:
         inc cx
         xor dx,dx
         div bx
         or dl,0x30
         push dx
         cmp ax,0
         jne @d

         ;以下显示各个数位 
     @a:
         pop dx
         mov [es:di],dl
         inc di
         mov byte [es:di],0x07
         inc di
         loop @a
       
         jmp near $ 
       

times 510-($-$$) db 0
                 db 0x55,0xaa
