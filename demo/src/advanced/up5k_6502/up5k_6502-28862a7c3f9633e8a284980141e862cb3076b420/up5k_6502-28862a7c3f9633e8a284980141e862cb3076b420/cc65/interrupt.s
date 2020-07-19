; ---------------------------------------------------------------------------
; interrupt.s
; up5k_6502 IRQ and NMI routines
; based on example code from https://cc65.github.io/doc/customizing.html
; 03-05-19 E. Brombaugh
; ---------------------------------------------------------------------------
;
; Interrupt handler.
;
; Checks for a BRK instruction, handles ACIA RX

.import   _rx_buffer, _rx_wptr, _rx_n
.import   _tx_buffer, _tx_rptr, _tx_n
.import   _acia_ctrl_shadow
.export   _irq_int, _nmi_int

.include  "fpga.inc"

.segment  "CODE"

; ---------------------------------------------------------------------------
; Non-maskable interrupt (NMI) service routine

_nmi_int:  RTI                    ; Return from all NMI interrupts

; ---------------------------------------------------------------------------
; Maskable interrupt (IRQ) service routine

_irq_int:           
           PHA                    ; Save accumulator contents to stack
           TXA                    ; Save X register contents to stack
           PHA
		   TYA                    ; Save Y register to stack
		   PHA
		   
; ---------------------------------------------------------------------------
; check for BRK instruction

           TSX                    ; Transfer stack pointer to X
           LDA $104,X             ; Load status register contents (SP + 4)
           AND #$10               ; Isolate B status bit
           BNE break              ; If B = 1, BRK detected

; ---------------------------------------------------------------------------
; check ACIA for IRQ

           LDA ACIA_CTRL
           AND #ACIA_STAT_IRQ     ; IRQ bit set?
           BEQ irq_exit           ; no - skip to exit
		   
; ---------------------------------------------------------------------------
; check for RX

           LDA ACIA_CTRL
           AND #ACIA_STAT_RXF     ; RXF bit set?
		   BEQ irq_chk_tx         ; no - skip to tx check
		   LDA ACIA_DATA          ; yes - read data, clear IRQ
		   LDY _rx_n              ; get rx buffer count
		   CPY #$80               ; room in buffer?
		   BPL irq_chk_tx         ; no - skip saving
		   LDX _rx_wptr           ; get rx buffer write index
		   STA _rx_buffer,X       ; save in buffer
		   INX                    ; inc index
		   TXA
		   AND #$7F               ; wrap index
		   STA _rx_wptr           ; save index
		   INY                    ; inc count
		   STY _rx_n              ; save to rx buffer count
		   
; ---------------------------------------------------------------------------
; check for TX

irq_chk_tx:
           LDA ACIA_CTRL
           AND #ACIA_STAT_TXE     ; TXE bit set?
		   BEQ irq_exit           ; no - skip to exit
		   LDY _tx_n              ; get tx buffer count
		   BEQ tx_skip            ; if buffer empty, skip tx
		   LDX _tx_rptr           ; get tx buffer read index
		   LDA _tx_buffer,X       ; get tx data
		   STA ACIA_DATA          ; send it
		   INX                    ; inc index
		   TXA
		   AND #$7F               ; wrap index
		   STA _tx_rptr           ; save index
		   DEY                    ; dec count
		   STY _tx_n              ; save count
		   BNE irq_exit           ; if buffer not empty then exit
		   
tx_skip:   LDA _acia_ctrl_shadow  ; get ctrl reg shadow
           AND #$D0               ; mask off tx IRQ enable
		   STA ACIA_CTRL
		   
; ---------------------------------------------------------------------------
; Restore state and exit ISR

irq_exit:  PLA                    ; Restore Y register contents
		   TAY
           PLA                    ; Restore X register contents
           TAX
           PLA                    ; Restore accumulator contents
           RTI                    ; Return from all IRQ interrupts

; ---------------------------------------------------------------------------
; BRK detected, stop

break:     JMP break              ; If BRK is detected, something very bad
                                  ;   has happened, so loop here forever
