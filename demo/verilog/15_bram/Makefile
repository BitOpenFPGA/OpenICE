filename = top
pcf_file = ../../pin_io/openice.pcf

ICEPROG = iceprog

build:
	yosys -p "synth_ice40 -blif $(filename).blif" $(filename).v
	arachne-pnr -d 5k -P sg48 -p $(pcf_file) $(filename).blif -o $(filename).asc
	icepack $(filename).asc $(filename).bin

recode:
	rm -f $(REAL_HEX) $(filename).bin
	$(MAKE) prog
    
prog: $(filename).bin
	$(ICEPROG)  $<

sudo-prog: $(filename).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG)  $<
# -S -IB
clean:
	rm -rf $(filename).blif $(filename).asc $(filename).bin
