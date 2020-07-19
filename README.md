OpeniCE
-----------
[中文](./README.md) [English](./README_en.md)

* [OpenICE介绍](#OpenICE介绍) 
* [芯片规格](#芯片规格)
* [硬件说明](#硬件说明)
	* [iCE40UP5K](iCE40UP5K)
	* [FTLink](FTLink)
* [资源下载](#虚拟机镜像)
* [开发环境搭建](#开发环境搭建)
* [视频教程](#视频教程)
* [FPGA教程](#fpga教程)
* [产品链接](#产品链接)
* [参考](#参考)


# OpenICE介绍 
OpenICE 是基于Lattice iCE40UP5k设计的开源FPGA开发板，开发板小巧精致，资源丰富，板载RGB LED，KEY，TYPE-C-USB, RESET，大部分IO以标准PMOD接口引出，可与标准PMOD外设进行对接，方便日常的开发使用。  
板载的调试器FTLINK是以FT2232H经过精心设计，支持官方的EDA进行下载调试，同时经过ICEProg就可实现轻松实现一些开源工具链的烧写。FTLINK亦支持虚拟串口以和FPGA进行通信。  
Lattice的iCE40系列芯片在国外的开源创客社区中拥有大量拥趸，其所有的开发软件环境亦均为开源。一般来说，假若您使用Xilinx或者Altera系列的开发板，您需要安装复杂臃肿的IDE开发环境(而且一般为盗版，使用存在一定法律风险), 在未开始开发前，首先还先需要学会如何操作其复杂的IDE。 iCE40则使用完全开源的工具链进行开发，包括FPGA综合（yosys），布线（arachne-pnr & nextpnr）, 打包烧录（icestorm），编译（gcc），只需在Linux下输入数条命令，即可将整套工具链轻松安装，随后即可开始您的FPGA之旅，而且这一切都是开源的，您可仔细研究整个过程中任何一个细节的实现，非常适合个人研究学习，对于有丰富经验的开发者，亦可用来作为快速的逻辑验证平台。典型的基于iCE40系列的开源开发板有iCEBreaker、UPduino、BlackIce、iCEstick、TinyFPGA 等，社区中拥有丰富的demo可用于验证测试，或者作为自己开发学习的参考。
![icesugar_render](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/doc/OpenICE-PCB.png)
![icesugar](https://github.com/OpenFPGA-ICE/OpenICE/blob/master/doc/OpenICE.jpg)

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




# 虚拟机镜像
链接：待更新 
提取码：
`user: ubuntu`  
`passwd: ubuntu`  
所有环境包括综合(yosys)，布线(nextpnr)，打包(icesorm)，编译器(gcc) 已经预制好，启动即可开始使用。

# 开发环境搭建
推荐使用虚拟机镜像进行开发测试，简单方便。  
FPGA工具链安装请参考[icestorm](http://www.clifford.at/icestorm/)  
gcc工具链安装请参考 [riscv-gnu-toolchain](https://pingu98.wordpress.com/2019/04/08/how-to-build-your-own-cpu-from-scratch-inside-an-fpga/)  
`icesprog`是为OpenICE开发的命令行烧写工具，仓库中已经提供，依赖libusb和hidapi，若自行搭建环境需要安装依赖的库  
`$sudo apt-get install libhidapi-dev`  
`$sudo apt-get install libusb-1.0-0-dev`  



# FPGA教程
强烈推荐学习此教程，[open-fpga-verilog-tutorial](https://github.com/Obijuan/open-fpga-verilog-tutorial/wiki/Home_EN) `src/basic/open-fpga-verilog-tutorial`目录中有对应的例程

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

