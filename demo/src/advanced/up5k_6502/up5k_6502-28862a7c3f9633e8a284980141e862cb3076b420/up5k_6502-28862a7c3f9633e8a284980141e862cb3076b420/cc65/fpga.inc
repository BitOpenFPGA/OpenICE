; ---------------------------------------------------------------------------
; fpga.inc
; handy info about locations in the FPGA
; 03-04-19 E. Brombaugh
; ---------------------------------------------------------------------------

.define   GPIO_DATA $D000    ;  GPIO data register location
.define   ACIA_CTRL $E000    ;  ACIA control register location
.define   ACIA_DATA $E001    ;  ACIA data register location

.define   ACIA_STAT_RXF $01  ;  RX full
.define   ACIA_STAT_TXE $02  ;  TX empty
.define   ACIA_STAT_ERR $10  ;  RX error
.define   ACIA_STAT_IRQ $80  ;  IRQ
