yosys -p "synth_ice40 -blif dial_switch.blif" dial_switch.v 

arachne-pnr -d 5k -p ../openice.pcf dial_switch.blif -o dial_switch.asc

icepack dial_switch.asc dial_switch.bin

