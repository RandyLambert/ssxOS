         ;�����嵥7-1
         ;�ļ�����c07_mbr.asm
         ;�ļ�˵����Ӳ����������������
         ;�������ڣ�2011-4-13 18:02
         
         jmp near start         ;����û��ָ������ݶ�
	
 message db '1+2+3+...+100='    ;���ݶ�
        
 start:
         mov ax,0x7c0           ;�������ݶεĶλ���ַ 
         mov ds,ax              ;��ʼ�����ݶμĴ���DS

         mov ax,0xb800          ;���ø��Ӷλ�ַ����ʾ������
         mov es,ax              ;��ʼ�����ӶμĴ���ES

         ;������ʾ�ַ��� 
         mov si,message          ;�������Ĵ���SIָ�����ݼĴ��DS�׵�ַ������š�message���������Ļ���ַ
         mov di,0                ;������һ�������Ĵ���DIָ��ES���ڵ�ƫ�Ƶ�ַ0����ES��ָ��0xb800��
         mov cx,start-message    ;����׶μ���һ��ѭ����������ѭ�����������ַ����ĳ���
     @g:
         mov al,[si]             ;ѭ����ִ�У���DS:SI�ĵط�ȡ���˵�һ���ַ�
         mov [es:di],al          ;���䴫�͵���ES:DI��ָ������ʾ������
         inc di                  ;DI�����ݼ�һ��ָ����ʾ��������������ֽ�
         mov byte [es:di],0x07   ;�ڸ�λ��д������0x07���ڵװ���
         inc di                  ;di�ٴμ�1
         inc si                  ;siҲ��1��һָ��Դ��ַ��Ŀ���ַ����һ����Ԫ
         loop @g                 ;����ѭ������loop��loopָ��Ĺ�����������CX�Ĵ���,loopָ����ִ��ʱ�Ƚ�cx�����ݽ���
                                 ;Ȼ����������cxʱ��Ϊ0�������Ƿ�ʼ��һ��ѭ������cxΪ0��ʱ��˵�������ַ��Ѿ���ʾ���
         ;���¼���1��100�ĺ� 
         xor ax,ax               ;��0ax�Ĵ���
         mov cx,1                ;��ʼ��cxΪ1
     @f:
         add ax,cx               ;ax����cx
         inc cx                  ;cx+1����һ��Ҫ�ӵ�����
         cmp cx,100              ;�Ƚ�cx�ǲ���100
         jle @f                  ;�������������������f������ִ��

         ;���¼����ۼӺ͵�ÿ����λ���ֽ������λ��׼��������Ļ��ʾ����������֪������鵽���Ƕ���
         xor cx,cx              ;���ö�ջ�εĶλ���ַ
         mov ss,cx              ;��ʼ��ջ��ss���μĴ���ssΪ0x0000
         mov sp,cx              ;��ʼ��ջָ��spΪ0x0000

         mov bx,10              ;��λ�ֽ⣬������10���͵��Ĵ���bx���Էֽ�ax�е������̶��Ƿֽ�5λ��65535�������γ������Ż���ÿ���ڷֽ��ʱ�����һ���ж�
         xor cx,cx              ;��cx��0������Ĵ�������ͳ���ۼ��ж��ٸ���λ
     @d:                        ;ѭ����
         inc cx                 ;��¼�ֽ��˼�����λ
         xor dx,dx              ;��dx���㣬��ax�γ���32λ�ı�����
         div bx                 ;��bx��10�����
         or dl,0x30             ;��dl�е��̼���0x30����or�ǻ�ָ���Ϊ����10���ڼĴ���dl�еõ�����������λ�ض�Ϊ0������Ϊ0x30����λ����0������ڼӣ���and������������������ͬʱΪ�ڴ浥Ԫ
         push dx                ;��8086�������£�pushֻ��ѹһ���֣���������32λ��64λ����ѹ�������ֵȣ�������ʱ��üӹؼ��֣��в���ѹ���ֽ�
         cmp ax,0               ;�Ƚϳ���֮���ǲ���0�������0�Ϳ����˳���
         jne @d                 ;��תָ��

         ;������ʾ������λ 
     @a:
         pop dx                 ;pop dxָ��Ĺ����ǽ��߼���ַss��sp
         mov [es:di],dl         ;��������������ʾ��������
         inc di                 ;���ַ���ʾ����д���ַ�֮��ĵ�Ԫ
         mov byte [es:di],0x07  ;
         inc di                 ;�ٴε���di��ָ����ʾ����������һ���ַ���λ��
         loop @a                ;ÿ��ִ��loopָ����뽫�Ĵ���cx��һ����������λ����������ʾ֮��cx�ض�Ϊ0���⽫����ѭ���˳�
                                ;�����������һ��ִ�г�ջ������վָ��Ĵ���sp�����ݽ��ָ����ʼ��״̬����������������Ϊ0
         jmp near $             ;
       

times 510-($-$$) db 0
                 db 0x55,0xaa