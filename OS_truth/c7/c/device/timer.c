#include "timer.h"
#include "io.h"
#include "print.h"

#define IRQ0_FREQUENCY	   100              //中断频率
#define INPUT_FREQUENCY	   1193180          //三个计数器的工作频率
#define COUNTER0_VALUE	   INPUT_FREQUENCY / IRQ0_FREQUENCY //多少次--,计数器的初始值,操作一次中断
#define CONTRER0_PORT	   0x40             //在使用计数器0的情况下往0x40端口写入数据
#define COUNTER0_NO	   0                    //使用计数器0
#define COUNTER_MODE	   2                //工作方式
#define READ_WRITE_LATCH   3                //是读写方式,职位3,这表示先读低8位,在读高8位
#define PIT_CONTROL_PORT   0x43         //向控制字寄存器端口0x43中写入控制字

/* 把操作的计数器counter_no、读写锁属性rwl、计数器模式counter_mode写入模式控制寄存器并赋予初始值counter_value */
static void frequency_set(uint8_t counter_port, \
			  uint8_t counter_no, \
			  uint8_t rwl, \
			  uint8_t counter_mode, \
			  uint16_t counter_value) {
/* 往控制字寄存器端口0x43中写入控制字 */
   outb(PIT_CONTROL_PORT, (uint8_t)(counter_no << 6 | rwl << 4 | counter_mode << 1));
/* 先写入counter_value的低8位 */
   outb(counter_port, (uint8_t)counter_value);
/* 再写入counter_value的高8位 */
   outb(counter_port, (uint8_t)counter_value >> 8);
}

/* 初始化PIT8253,最终做初始化工作的是frequency_set函数,它在第32行被调用,定义在15行 */
void timer_init() {
   put_str("timer_init start\n");
   /* 设置8253的定时周期,也就是发中断的周期 */
   frequency_set(CONTRER0_PORT, COUNTER0_NO, READ_WRITE_LATCH, COUNTER_MODE, COUNTER0_VALUE);
   put_str("timer_init done\n");
}
