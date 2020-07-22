; ---------------------------------------------------------------------------
; acia_ll.s
; 6502 ACIA low-level interface routines
; 03-04-19 E. Brombaugh
; ---------------------------------------------------------------------------
;
; Write a string to the ACIA TX

.export         _acia_tx_str
.export         _acia_tx_chr
.export         _acia_rx_chr
.exportzp       _acia_data: near

.include  "fpga.inc"

.zeropage

_acia_data:     .res 2, $00        ;  Reserve a local zero page pointer

.segment  "CODE"

; ---------------------------------------------------------------------------
; send a string to the ACIA

.proc _acia_tx_str: near

; ---------------------------------------------------------------------------
; Store pointer to zero page memory and load first character

        sta     _acia_data       ;  Set zero page pointer to string address
        stx     _acia_data+1     ;    (pointer passed in via the A/X registers)
        ldy     #00              ;  Initialize Y to 0
        lda     (_acia_data),y   ;  Load first character

; ---------------------------------------------------------------------------
; Main loop:  read data and store to FIFO until \0 is encountered

loop:   jsr     _acia_tx_chr     ;  Loop:  send char to ACIA
        iny                      ;         Increment Y index
        lda     (_acia_data),y   ;         Get next character
        bne     loop             ;         If character == 0, exit loop
        rts                      ;  Return
.endproc
        
; ---------------------------------------------------------------------------
; wait for TX empty and send single character to ACIA

.proc _acia_tx_chr: near

        pha                      ; temp save char to send
txw:    lda      ACIA_CTRL       ; wait for TX empty
        and      #$02
        beq      txw
        pla                      ; restore char
        sta      ACIA_DATA       ; send
        rts

.endproc

; ---------------------------------------------------------------------------
; wait for RX full and get single character from ACIA

.proc _acia_rx_chr: near

rxw:    lda      ACIA_CTRL       ; wait for RX full
        and      #$01
        beq      rxw
        lda      ACIA_DATA       ; receive
        rts

.endproc
