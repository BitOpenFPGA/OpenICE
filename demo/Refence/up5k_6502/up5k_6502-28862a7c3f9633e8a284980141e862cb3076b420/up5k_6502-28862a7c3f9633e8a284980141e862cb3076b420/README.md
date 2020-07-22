# up5k_6502
A simple 6502 system built on a Lattice Ultra Plus 5k FPGA. This system
includes 32kB SRAM (using one of the four available SPRAM cores), 8 bits
input, 8 bits output, a 9600bps serial I/O port and 4kB of ROM which is
pre-loaded with code & vectors built from the cc65 C compiler. The code
currently loaded simply prints startup message, counts on the output port
and echos any serial data. It can easily be extended for up to 15kB ROM,
128kB RAM and currently only uses only about 20% of the logic cells
available so there's plenty of room for more peripherals.

## prerequisites
To build this you will need the following FPGA tools

* Icestorm - ice40 FPGA tools
* Yosys - Synthesis
* Nextpnr - Place and Route

Info on these can be found at http://www.clifford.at/icestorm/

You will also need the following 6502 tools:

* cc65 6502 C compiler (for default option) https://github.com/cc65/cc65

## Building

	git clone https://github.com/emeb/up5k_6502.git
	cd up5k_6502
	git submodule update --init
	cd icestorm
	make

## Running

I built this system on a upduino and programmed it with a custom USB->SPI
board that I built so you will definitely need to tweak the programming
target of the Makefile in the icestorm directory to match your own hardware.

## CPU coding

The build system fills the ROM with code based on the C and assembly
source in the cc65 directory. This is automatically built when running make
within the icestorm directory, but you can also enter the cc65 directory to 
work on the ROM code.

	cd cc65
	make

Note that the files "fpga.inc" and "fpga.h" contain assembly and C definitions
of the FPGA I/O resources and need to be kept in sync with the verilog design
by hand at the moment. The linker configuration file "sbc.cfg" contains the
RAM and ROM memory map. More detail about how all this fits together can be
found on the cc65 website.

## Simulating

Simulation is supported and requires the following prerequisites:

* Icarus Verilog simulator http://iverilog.icarus.com/
* GTKWave waveform viewer http://gtkwave.sourceforge.net/

To simulate, use the following commands

	cd icarus
	make
	make wave

This will build the simulation executable, run it and then view the output.

## Thanks

Thanks to the developers of all the tools used for this, as well as the authors
of the IP cores I snagged for the 6502 and UART. I've added those as submodules
so you'll know where to get them and who to give credit to.
