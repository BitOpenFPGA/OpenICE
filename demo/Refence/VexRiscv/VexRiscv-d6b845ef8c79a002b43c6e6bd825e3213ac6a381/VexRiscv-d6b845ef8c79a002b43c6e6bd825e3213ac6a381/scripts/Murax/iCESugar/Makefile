VERILOG = ../../../Murax.v toplevel.v

generate :
	(cd ../../..; sbt "runMain vexriscv.demo.MuraxWithRamInit")

../../../Murax.v :
	(cd ../../..; sbt "runMain vexriscv.demo.MuraxWithRamInit")

../../../Murax.v*.bin:

bin/toplevel.blif : ${VERILOG} ../../../Murax.v*.bin
	mkdir -p bin
	rm -f Murax.v*.bin
	cp ../../../Murax.v*.bin . | true
	yosys -v3 -p "synth_ice40 -top toplevel -blif bin/toplevel.blif" ${VERILOG}

bin/toplevel.asc : io.pcf bin/toplevel.blif
	arachne-pnr -p io.pcf -d 5k --max-passes 600 -P sg48 bin/toplevel.blif -o bin/toplevel.asc

bin/toplevel.bin : bin/toplevel.asc
	icepack bin/toplevel.asc bin/toplevel.bin

compile : bin/toplevel.bin

time: bin/toplevel.bin
	icetime -tmd hx8k bin/toplevel.asc

prog : bin/toplevel.bin
	icesprog bin/toplevel.bin

clean :
	rm -f ../../../Murax.v
	rm -rf bin
	rm -f Murax.v*.bin
