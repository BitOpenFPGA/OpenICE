# 基于开源FPGA-OpeniCE的NES游戏
![OpenNES](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/demo/Refence/up5k-demos/nes/image/%E5%B0%8F%E9%9C%B8%E7%8E%8BFC%E6%B8%B8%E6%88%8F%E6%9C%BA.jpg?raw=true)

## 硬件连接
所需硬件
### [PMOD VGA扩展板](https://github.com/OpenFPGA-ICE/OpenICE/tree/master/Hardware/PMOD_SubCard/VGA)
### [PMOD NES扩展板](https://github.com/OpenFPGA-ICE/OpenICE/tree/master/Hardware/PMOD_SubCard/NES)
### FC手柄
最好选用原装手柄。

手柄的协议如图所示：
![OpenNES](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/demo/Refence/up5k-demos/nes/image/FC%E6%89%8B%E6%9F%84%E4%BF%A1%E5%8F%B7%E5%AE%9A%E4%B9%89.jpg?raw=true)
原理比较简单：协议共有3个信号，Latch、Clock、Data、Latch用于锁存按键值，给一个Latch高电平脉冲，然后在每个clock周期的低电平时读Data，即可依次读出8个按键的值，A、B、SELECT、START、Up、Down、Left、Right。VCC可以直接接3.3V即可。（注意实际上Clock只需7拍即可，Latch脉冲低电平后即可读出第一个按键A的值，后续7个Clock脉冲读出其他7个按键）

### 扬声器
将上诉硬件和主板按照下面图片连接
![OpenNES](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/demo/Refence/up5k-demos/nes/image/NES%20Games.png?raw=true)
## 综合编译下载
```
git clone https://github.com/OpenFPGA-ICE/OpenICE/tree/master/demo/Refence/up5k-demos/nes
cd nes
make
```
make会综合出FC系统的bitstream文件nes.bin，使用icesprog可以进行烧录

```sudo icesprog nes.bin```

随后，需要将游戏ROM文件打包并烧录至flash偏移1M中，FC启动之后会从此处读ROM文件运行。
```
cd rom
sudo chmod 777 nes2bin
./nes2bin.py games/139.nes 139.bin
sudo chmod 777 139.bin
sudo icesprog -o 0x100000 139.bin
```
烧写的游戏是绿色军团，也可自行打包其他nes游戏，可以到[52nes](http://www.52nes.com/)下载其他游戏。
<rom/games>下有以下几种游戏：
超时空要塞无敌版             Beyondtime
93超级魂斗罗(中文)          93-contra
绿色兵团无限人                 76 
绿色兵团金身无敌版          92
赤色要塞无敌版                 139
冒险岛经典版                     smb


## 演示视频

[B站演示视频](https://www.bilibili.com/video/bv1G54y1U7yN)