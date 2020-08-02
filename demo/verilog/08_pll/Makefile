filename = top
pcf_file = ../../pin_io/openice.pcf

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')
${warning iCELink path: $(ICELINK_DIR)}

build:
	yosys -p "synth_ice40 -json $(filename).json -blif $(filename).blif" $(filename).v
	# arachne-pnr -d 5k -P sg48 -p $(pcf_file) $(filename).blif -o $(filename).asc
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc --freq 48
	icepack $(filename).asc $(filename).bin

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).bin
