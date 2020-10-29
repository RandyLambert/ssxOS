# 只编译生成main.o
gcc -c -o main.o main.c
# -Ttext 指定起始的虚拟地址为0xc0001500
ld main.o -Ttext 0xc0001500 -e main -o kernel.bin 

