# Port of the MIST NES core to ice40

This port of the NES MIST core is currently designed for the upduino 
board, with a VGA DAC and connection to a NES controller added.

Currently it can run any NROM, MMC1, UNROM or CNROM game requiring 
either less than 64kB PRG and CHR ROM, or less than 128kB PRG ROM and 
8kB CHR RAM. Sound is a tiny bit big for the 5k UltraPlus so is not 
included. By removing all the mappers - and some registers needed for 
reliable performance - you can  just about get it to fit  but it uses 
every single PLB in the device.

It would be much better suited to a 8k board with more external RAM. 
Then you would have room for bigger games (up to the size of the board's 
RAM), more mapper support (e.g. MMC3) and sound. The only changes needed 
would be changing cart_mem to use external RAM instead of UltraPlus 
SPRAM, and creating a new Makefile and pcf file.

'Streaming' games from SQI flash might be just about doable from a 
timing point of view but I don't think there are enough PLBs available 
at present on the 5k, and it would probably be quite a bit of work for 
it to work reliably.

I'll probably port this to my icoBoard with a VGA PMOD at some point, 
which could end up being a very nice platform for this.

Credit to the original developer of the NES core, Ludvig Strigeus for 
making such an awesome project! Like the original core this is licensed 
under the GNU GPL.
