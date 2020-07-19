/*
 * acia.h - C interface to the acia assembly routines
 * 03-04-19 E. Brombaugh
 */

#ifndef __ACIA__
#define __ACIA__

// low-level routines
extern void __fastcall__ acia_tx_str (char *str);
extern void __fastcall__ acia_tx_chr (char c);
extern char __fastcall__ acia_rx_chr (void);

// C routines
void acia_reset(unsigned char state);
void acia_tx_irq_ena(unsigned char state);
void acia_rx_irq_ena(unsigned char state);
int acia_getc(void);
void acia_putc(char c);
void acia_puts(char *str);

#endif
