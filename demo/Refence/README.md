# picorv32  
https://github.com/cliffordwolf/picorv32.git
## build & run
`picocom -b 115200 /dev/ttyACM0`
`make icesprog`

# VexRiscv
https://github.com/wuxx/VexRiscv.git 
## build & run
`picocom -b 115200 /dev/ttyACM0`
`cd scripts/Murax/iCESugar && make prog`

# icicle  
https://github.com/grahamedgecombe/icicle.git
## build & run
`picocom -b 9600 /dev/ttyACM0`
`make BOARD=icesugar flash`

# litex-fupy
https://github.com/wuxx/litex-buildenv.git
## build 
`picocom -b 115200 /dev/ttyACM0`
`./build_micropython.sh`
## how to test: connect the P27 to a LED
>>import litex
>>l = litex.LED(1)
>>l.on()
>>l.off()


# up5k_6502    (commit-id 18610cb)
https://github.com/emeb/up5k_6502.git
## build & run
`picocom -b 9600 /dev/ttyACM0`
`cd icestorm && make && make prog`

# iceZ0mb1e
https://github.com/wuxx/iceZ0mb1e.git
## build & run
`picocom -b 9600 /dev/ttyACM0`
`make firmware && make fpga && make flash`
