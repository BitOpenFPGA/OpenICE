/*
 * main.c - top level 6502 C code for up5k_6502
 * 03-05-19 E. Brombaugh
 * based on example code from https://cc65.github.io/doc/customizing.html
 */
 
#include <stdio.h>
#include "fpga.h"
#include "acia.h"
#include "cmd.h"

char *msg = "\n\n\rup5k 6502 cc65 serial test\n\n\r";
unsigned long cnt;
unsigned char x = 0;

int main()
{
	// enable ACIA RX IRQ
	acia_rx_irq_ena(1);
	asm("CLI");
	
	// Send startup message
	acia_puts(msg);
	
	// initialize and print prompt
	cmd_init();
	
    // Run forever
    while(1)
    {
		// delay
		cnt = 4096L;
		while(cnt--)
		{
		}
		
        // write counter msbyte to GPIO
        GPIO_DATA = x;
        ++x;
		
		// process commands
		cmd_do();
    }

    //  We should never get here!
    return (0);
}
