# ssxOS

```
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄       ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌     ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀  ▐░▌   ▐░▌ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ 
▐░▌          ▐░▌            ▐░▌ ▐░▌  ▐░▌       ▐░▌▐░▌          
▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄    ▐░▐░▌   ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌    ▐░▌    ▐░▌       ▐░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀█░▌   ▐░▌░▌   ▐░▌       ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌
          ▐░▌          ▐░▌  ▐░▌ ▐░▌  ▐░▌       ▐░▌          ▐░▌
 ▄▄▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌ ▐░▌   ▐░▌ ▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌     ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀       ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀ 
                                                               
```

> 一个小型操作系统的学习与实现

### 开发环境

操作系统版本: 5.4.70-amd64-desktop
类型: 64位
处理器: Intel(R) Core(TM) i7-8750H CPU @2.20GHz
编译器版本: GCC 9.3
nasm 版本: 2.14
bochs 版本: 2.6.9
dd 版本: 8.3

### 如何运行

1. 请在运行之前确保你使用的 Linux 发型版本之下中拥有 gcc , bochs , dd , nasm , bximage 命令,以上命令在Debian/Ubuntu 环境下都可以直接通过软件包直接安装,当然网上也能很容易查到相应的安装教程.

	```bash
	sudo install apt-get xx
	```

2. 通过 bximage 命令生成硬盘,然后放到固定的一个目录下(我选择放在 /usr/share/bochs/ ),有两种方式.

   - 方式一: 直接通过输入命令(但是我的 bximage 版本无法执行该语句).

     ```bash
     bximage -hd -mode="flat" -size=60 -q hd60M.img
     ```

   - 方式二: 命令行输 bximage 交互生成硬盘.

    ![在这里插入图片描述](https://img-blog.csdnimg.cn/20201224231411870.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3NDk2Mg==,size_16,color_FFFFFF,t_70#pic_center)


3. 按照自己的实际开发环境创建 bochsrc.disk 文件,可以参考我的 bochsrc.disk 文件写法.
4. 修改 Makefile 中的 img 路径为自己硬盘路径,例如
	```bash
	img=/usr/share/bochs/hd60M.img
	```
6. 在主目录运行 make all 和 make image 命令.

7. 运行 bochs -f bochsrc.disk所在路径,例如: 

	```bash
	bochs -f bochsrc.disk
	```

之后就可以通过 bochs 进行调试运行了.
### 运行截图
![在这里插入图片描述](https://img-blog.csdnimg.cn/20201224232048157.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzU3NDk2Mg==,size_16,color_FFFFFF,t_70#pic_center)


### 参考书籍 

- 《X86汇编语言 从实模式到保护模式》
- 《操作系统真相还原》
- 《程序员的自我修养》
- 《深入理解计算机系统》
- 还有很多的博客文章,再次不一一列举了,十分感谢.
