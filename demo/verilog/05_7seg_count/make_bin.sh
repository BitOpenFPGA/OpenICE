yosys -p "synth_ice40 -blif 7seg_count.blif" 7seg_count.v 

arachne-pnr -d 5k -p ../openice.pcf 7seg_count.blif -o 7seg_count.asc

icepack 7seg_count.asc 7seg_count.bin

