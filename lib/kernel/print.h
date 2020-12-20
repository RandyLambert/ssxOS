#ifndef __LIB_KERNEL_PRINT_H
#define __LIB_KERNEL_PRINT_H
#include "stdint.h"
void put_char(uint8_t char_asci); // 打印字符
void put_str(char* message); // 通过封装打印字符来打印字符串
void put_int(uint32_t num);	 // 以16进制打印
void set_cursor(uint32_t cursor_pos);
#endif

