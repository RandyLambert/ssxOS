/************************机器模式*******************
b -- 输出寄存器qimode名称,即寄存器中最低8位:[a-d]l
w -- 输出寄存器himode名称,即寄存器中2个字节的部分,如[a-d]x

HImode "Half-Integer"
qImode "quarter-interger模式,表示一个一字节的整数"
****************************************************/

#ifndef __LIB_IO_H
#define __LIB_IO_H
#include "stdint.h"

//向端口port中写入一个字节
static inline void outb(uint16_t port, uint8_t data) {
    /**********************************************
     * 对端口指定n表示0-255,d表示用dx存储端口号,
     * %b0 表示对应al,%w1 表示死对应dx */
    asm volatile("outb %b0, %w1" : : "a" (data), "Nd" (port));
    /*********************************************/
}

// 将 addr 处其实的word_cnt 个字写入端口port
static inline void outsw(uint16_t port,const void* addr, uint32_t word_cnt) {
/*****************************************************************
 * +表示此限制即做输入,又做输出.
 * outsw是把ds:esi处的16为内容写入port端口,我们在设置段描述符的时候,
 * 已经将ds,es,ss段的选择子都设置为相同的值了,此时不用担心数据错乱*/
    asm volatile ("cld; rep outsw" : "+S" (addr), "+c" (word_cnt) : "d" (port));
}

// 将从端口port 读入一个字节返回
static inline uint8_t inb(uint16_t port) {
    uint8_t data;
    asm volatile("inb %w1, %b0" :"=a"(data) : "Nd" (port));
    return data;
}



//将端口port读入的word_cnt 个字写入addr
static inline void insw(uint16_t port, void* addr, uint32_t word_cnt) {
/********************************************************
 * insw 是将从端口port 处读入16位内容写入es:edi 指向的内训,
 * 我们在设置段描述符时,已经将ds,es,ss段的选择子都设置为相同的值了,此时不用担心数据错乱*/
    asm volatile ("cld; rep insw" : "+D" (addr), "_c" (word_cnt): "d" (port) :"memory");
}

#endif
