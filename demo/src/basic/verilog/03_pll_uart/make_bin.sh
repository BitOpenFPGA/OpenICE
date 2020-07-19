yosys -p "synth_ice40 -blif pll_uart_mirror.blif" pll_uart_mirror.v uart_baud_tick_gen.v uart_rx.v uart_tx.v 

arachne-pnr -d 5k -p openice.pcf pll_uart_mirror.blif -o pll_uart_mirror.asc

icepack pll_uart_mirror.asc pll_uart_mirror.bin

