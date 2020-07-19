/*
 * acia.c - interface routines for the ACIA
 * 03-05-19 E. Brombaugh
 */

#include <stdio.h>
#include "acia.h"
#include "fpga.h"

// only allow 2^N buffer sizes to make masking easy
#define ACIA_BUFSZ 128
#define ACIA_BUFMASK (ACIA_BUFSZ-1)

// ACIA buffers
char tx_buffer[ACIA_BUFSZ], rx_buffer[ACIA_BUFSZ];
unsigned char tx_wptr = 0, tx_rptr = 0, tx_n = 0,
				rx_wptr = 0, rx_rptr = 0, rx_n = 0,
				acia_ctrl_shadow = 0;

/*
 * set/clear ACIA master reset
 */
void acia_reset(unsigned char state)
{
	if(state)
		acia_ctrl_shadow |= ACIA_CTRL_CDIVSEL_MR;
	else
		acia_ctrl_shadow &= ~ACIA_CTRL_CDIVSEL_MASK;
	
	ACIA_CTRL = acia_ctrl_shadow;
}

/*
 * set/clear ACIA TX IRQ enable
 */
void acia_tx_irq_ena(unsigned char state)
{
	if(state)
		acia_ctrl_shadow |= ACIA_CTRL_TXIE_ENA;
	else
		acia_ctrl_shadow &= ~ACIA_CTRL_TXIE_MASK;
	
	ACIA_CTRL = acia_ctrl_shadow;
}

/*
 * set/clear ACIA RX IRQ enable
 */
void acia_rx_irq_ena(unsigned char state)
{
	if(state)
		acia_ctrl_shadow |= ACIA_CTRL_RXIE_ENA;
	else
		acia_ctrl_shadow &= ~ACIA_CTRL_RXIE_MASK;
	
	ACIA_CTRL = acia_ctrl_shadow;
}

/*
 * C code for RX/TX circular buffers - unused since ISR is in assy only
 */
#if 0
/*
 * ACIA handler called from the global ISR
 */
void acia_irq_handler(void)
{
	unsigned char c;
	
	// check for RX data full
	if(ACIA_STAT & ACIA_STAT_RXF)
	{
		// get rx data regardless
		c = ACIA_DATA;
		
		// check if there's room in the buffer
		if(rx_n <= ACIA_BUFSZ)
		{
			// save in buffer and update status
			rx_buffer[rx_wptr] = c;
			rx_wptr = (rx_wptr+1)&ACIA_BUFMASK;
			++rx_n;
		}
	}
	
	// check for TX data empty
	if(ACIA_STAT & ACIA_STAT_TXE)
	{
		// check for TX data
		if(tx_n)
		{
			// send character
			ACIA_DATA = tx_buffer[tx_rptr];
			
			// update pointer w/ wrap
			tx_rptr = (tx_rptr+1)&ACIA_BUFMASK;
			
			// update counter
			--tx_n;
			
			// if buffer empty then disable TX IRQ
			if(!tx_n)
				acia_tx_irq_ena(0);
		}
		else
		{
			// no data remaining so disable TX IRQ
			acia_tx_irq_ena(0);
		}
	}
}
#endif

/*
 * get a character from the RX buffer
 */
int acia_getc(void)
{
	int result;
	
	// check if data available
	if(rx_n)
	{
		// get char from buffer
		result = rx_buffer[rx_rptr];
		
		// update read ptr and count atomically
		asm("SEI");		// disable IRQ
		rx_rptr = (rx_rptr+1)&ACIA_BUFMASK;
		--rx_n;
		asm("CLI");		// enable IRQ
	}
	else
		result = EOF;
	
	return result;
}

/*
 * put a character in the TX buffer
 */
void acia_putc(char c)
{
	// block until there's room in the buffer
    while(tx_n >= ACIA_BUFSZ) {}
	
	// put char in buffer
	tx_buffer[tx_wptr] = c;
	
	// update count and pointer atomically
	asm("SEI");		// disable IRQ
	tx_wptr = (tx_wptr+1)&ACIA_BUFMASK;
	++tx_n;
	
	// enable TX IRQ if buffer not empty
	if(tx_n)
		acia_tx_irq_ena(1);
	asm("CLI");		// enable IRQ
}

/*
 * put a string to the TX buffer
 */
void acia_puts(char *str)
{
	char x=0, c;
	
	// loop over null terminated string 255 max
	// note - using pointer dereferencing or postincrement breaks this
	while(x<255)
	{
		// get next char
		c = str[x];
		++x;	// had to do this here - bugs in cc65?
		
		// break if null
		if(c==0)
			break;
		
		// send char
		acia_putc(c);		
	}
}
