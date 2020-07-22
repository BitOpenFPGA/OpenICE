OpeniCE
-----------
[中文](./README.md)

* [来源 ](#来源 ) 
* [OpenICE介绍](#OpenICE介绍) 
* [芯片规格](#芯片规格)
* [硬件说明](#硬件说明)
	* [iCE40UP5K](iCE40UP5K)
* [开发环境搭建](#开发环境搭建)
* [FPGA教程](#fpga教程)
* [参考](#参考)



# 来源 

开源FPGA应具备几个维度特点：



![icesugar_render](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/doc/%E6%9E%84%E5%9B%BE.png?raw=true)



其中最难弄得就是工具链了，经过长时间查找，终于在GitHub上找到了一个FPGA的开源工具链Yosys，选择的理由如下：

Intel Quartus II （No ）License

Xilinx Vivado ISE (No) License

Lattice Diamond (No) License 注册可以免费申请，但是随时可以收回（一般不会）

 

 Yosys, nextpnr, icestorm, iverilog, symbiflow （YES） 整个工具链开源

 

 

支持的硬件：

http://www.clifford.at/icestorm/

 

折中选择ICE40UP5K-SG48芯片。

为什么选择ICE40系列FPGA呢？

Lattice的iCE40系列芯片在国外很受欢迎，大部分的开发环境都是开源的，不需要担心License所带来的限制，只需要将工具链进行安装之后就可以进行FPGA的开发之路，典型的基于iCE40系列的开源开发板有iCEBreaker、UPduino、BlackIce、iCEstick、TinyFPGA 等。

每个开发版对比如下：
表格来源：https://www.crowdsupply.com/1bitsquared/icebreaker-fpga

|                                         | iCEBreaker                       | TinyFPGA BX        | Tomu FPGA          | Lattice ICEstick              | UPDuino v2.0                  | ICE40UP5K Breakout            | Alhambra II                  | ICE40HX8K Breakout            |
| :-------------------------------------- | :------------------------------- | :----------------- | :----------------- | :---------------------------- | :---------------------------- | :---------------------------- | :--------------------------- | :---------------------------- |
| License                                 | OSHW                             | OSHW               | OSHW               | Closed                        | Closed                        | Closed                        | OSHW                         | Closed                        |
| Price                                   | $65                              | $38                | $??                | ~$25                          | $13.99                        | $49                           | $59.90                       | $49                           |
| Schematics Published?                   | Yes                              | Yes                | Not Yet            | Yes                           | Yes                           | Yes                           | Yes                          | Yes                           |
| Design files Published?                 | Yes                              | Yes                | Not Yet            | No                            | Yes                           | No                            | Yes                          | No                            |
| **FPGA**                                |                                  |                    |                    |                               |                               |                               |                              |                               |
| Model                                   | iCE40UP5K                        | iCE40LP8K          | iCE40UP5K          | iCE40HX1K                     | iCE40UP5K                     | iCE40UP5K                     | iCE40HX4K(8K)                | iCE40HX8K                     |
| Logic Capacity (LUTs)                   | 5280                             | 7680               | 5280               | 1280                          | 5280                          | 5280                          | 3520 (7680)                  | 7680                          |
| Internal RAM (bits)                     | 120k + 1024k                     | 128k               | 120k + 1024k       | 64k                           | 120k + 1024k                  | 120k + 1024k                  | 80k                          | 128k                          |
| Multipliers                             | 8                                | 0                  | 8                  | 0                             | 8                             | 8                             | 0                            | 0                             |
| **Peripherals**                         |                                  |                    |                    |                               |                               |                               |                              |                               |
| USB Interface                           | FTDI 2232HQ                      | On FPGA Bootloader | On FPGA Bootloader | FTDI 2232HL                   | FTDI 232HQ                    | FTDI 2232HL                   | FTDI 2232HQ                  | FTDI 2232HL                   |
| USB HS FIFO/SPI interface to the FPGA   | Yes through Jumper Mod           | No                 | No                 | No                            | No                            | No                            | No                           | No                            |
| USB Serial (UART) interface to the FPGA | Yes                              | No                 | No                 | Yes                           | No                            | Yes                           | Yes                          | Yes                           |
| GPIO inline termination resistors       | Yes 33 Ohm                       | No                 | No                 | No                            | No                            | No                            | Yes 300 Ohm                  | No                            |
| User IOs                                | 27 + 7                           | 41 + 2             | 4 + 2              | 18                            | 34                            | 34 + 2                        | 20                           | 90 + 10                       |
| Pmod Connectors                         | 3                                | 0                  | 0                  | 1                             | 0                             | 1                             | 0                            | 0                             |
| User Buttons                            | 1 Tact + 3 Tact on Breakoff Pmod | 1 CRESET           | 2 Capacitive       | 0                             | 0                             | 4 DIP                         | 2 Tact                       | 0                             |
| User LED                                | 2 + 5 on Breakoff Pmod           | 1                  | 0                  | 5                             | 1 RGB                         | 1 RGB                         | 8                            | 8                             |
| Indicator LED                           | PWR, CDONE                       | PWR                |                    |                               | CDONE, FTDI-TX/RX             | PWR, CDONE                    | PWR, CDONE, FTDI-TX/RX       | PWR, CDONE                    |
| Onboard Clock                           | 12 MHz MEMS Shared with FTDI     | 16 MHz MEMS        | 12 MHz MEMS        | 12 MHz MEMS? Shared with FTDI | 12 MHz MEMS? Shared with FTDI | 12 MHz MEMS? Shared with FTDI | 12 MHz MEMS Shared with FTDI | 12 MHz MEMS? Shared with FTDI |
| Flash                                   | 128 Mbit QSPI DDR                | 8 Mbit SPI         | 16 Mbit SPI        | 32 Mbit SPI                   | 32 Mbit SPI                   | 32 Mbit SPI                   | 32 Mbit SPI                  | 32 Mbit SPI                   |
| **FPGA Power Delivery**                 |                                  |                    |                    |                               |                               |                               |                              |                               |
| Dedicated GND/Power Planes              | Yes                              | Yes                | No                 | Yes                           | No                            | Yes                           | Yes                          | Yes                           |
| Dedicated FPGA Bypass Capacitors        | 19                               | 8                  | 9                  | 18                            | 2                             | 19                            | ?                            | ?                             |
| IO GND Connections                      | 11                               | 6                  | 1                  | 4                             | 3                             | 8                             | 22                           | 20                            |
| **Software**                            |                                  |                    |                    |                               |                               |                               |                              |                               |
| Open Source Toolchain                   | Yes                              | Yes                | Yes                | Yes                           | Yes                           | Yes                           | Yes                          | Yes                           |
| APIO                                    | Yes                              | Yes                | Yes                | Yes                           | Yes                           | Yes                           | Yes                          | Yes                           |
| icestudio                               | Yes                              | Yes                | Not Yet            | Yes                           | Yes                           | Yes                           | Yes                          | Yes                           |
| migen                                   | Yes                              | Yes                | No                 | Yes                           | No                            | Yes                           | No                           | Yes                           |



硬件上也可以参考：https://github.com/icebreaker-fpga/icebreaker-examples
https://github.com/wuxx/icesugar



其中icebreaker可以直接采购，但是国内买还是偏难，而且价格上也比较贵，icesugar由于不是使用官方的下载方式，不支持官方的EDA，这样在使用过程中还是有一些限制，综合考虑还是自己参考官方的DEMO和icebreaker自己做，原则上尽量减少改动。




# OpenICE介绍 
OpenICE 是基于Lattice iCE40UP5k设计的开源FPGA开发板，开发板以Arduino为原型进行设计，资源丰富，板载RGB LED，KEY，TYPE-C-USB, RESET，大部分IO以标准PMOD接口引出，可与标准PMOD外设进行对接，方便日常的开发使用。  
板载的调试器以FT2232H为核心设计，支持官方的EDA进行下载调试，同时经过ICEProg就可实现轻松实现一些开源工具链的烧写。FTLINK亦支持虚拟串口以和FPGA进行通信。  

整版的原理框图如下：

![icesugar](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/doc/%E6%A1%86%E5%9B%BE.png?raw=true)

PCB截图如下：

![icesugar_render](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/doc/OpenICE-PCB.png?raw=true)
![icesugar](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/doc/OpenICE.jpg?raw=true)

# 芯片规格 
iCE40UP5K-SG48  
1. 5280 Logic Cells (4-LUT + Carry + FF)  
2. 128 KBit Dual-Port Block RAM  
3. 1 MBit (128 KB) Single-Port RAM  
4. PLL, Two SPI and two I2C hard IPs  
5. Two internal oscillators (10 kHz and 48 MHz)  
6. 8 DSPs (16x16 multiply + 32 bit accumulate)  
7. 3x 24mA drive and 3x hard PWM IP  

# 硬件说明
### iCE40UP5K
1. SPI Flash使用W25Q64（8MB）/W25Q128(16MB)
2. 板载按键开关、LED和RGB LED可用于测试
3. 所有IO以标准PMOD接口引出，可用于开发调试
4. 板载电源指示灯V8，方便查看整版电源情况



# 开发环境搭建
推荐使用虚拟机镜像进行开发测试，简单方便。  
FPGA工具链安装请参考[icestorm](http://www.clifford.at/icestorm/)  
gcc工具链安装请参考 [riscv-gnu-toolchain](https://pingu98.wordpress.com/2019/04/08/how-to-build-your-own-cpu-from-scratch-inside-an-fpga/)  
`icesprog`是为OpenICE开发的命令行烧写工具，仓库中已经提供，依赖libusb和hidapi，若自行搭建环境需要安装依赖的库  
`$sudo apt-get install libhidapi-dev`  
`$sudo apt-get install libusb-1.0-0-dev`  



# FPGA教程
[open-fpga-verilog-tutorial](https://github.com/Obijuan/open-fpga-verilog-tutorial/wiki/Home_EN) `src/basic/open-fpga-verilog-tutorial`目录中有对应的例程

# 产品链接


# 参考
### toolchain
http://www.clifford.at/icestorm/
### examples
https://github.com/damdoy/ice40_ultraplus_examples  
https://github.com/icebreaker-fpga/icebreaker-examples
https://github.com/wuxx/icesugar

### SpinalHDL 教程
https://spinalhdl.github.io/SpinalDoc-RTD/SpinalHDL/Getting%20Started/index.html
### 开源FPGA单板OpenICE介绍
https://github.com/OpenFPGA-ICE/OpenICE/blob/master/README.md
