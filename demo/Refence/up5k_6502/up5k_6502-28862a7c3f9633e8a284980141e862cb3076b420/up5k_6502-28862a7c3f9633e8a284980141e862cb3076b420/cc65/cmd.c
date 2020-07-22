/*
 * cmd.c - process commands
 * 03-06-19 E. Brombaugh
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cmd.h"
#include "acia.h"

#define MAX_CMD_LEN 128
#define MAX_ARGS 4

const char *cmd_commands[] =
{
	"help",
	"peek",
	"poke",
	""
};

char cmd_buff[MAX_CMD_LEN], text_buffer[80];
unsigned char cmd_widx;

/*
 * emit the command prompt
 */
void cmd_prompt(void)
{
	cmd_widx = 0;
	acia_puts("Command>");
}

/*
 * handle a command line
 */
void cmd_parse(void)
{
	char *token, *argv[MAX_ARGS];
	int argc, cmd;
	unsigned int addr;
	unsigned char data;
	
	// parse out three tokens: cmd arg arg
	argc = 0;
	token = strtok(cmd_buff, " ");
	while((token != NULL) && (argc < MAX_ARGS))
	{
		argv[argc] = token;
		++argc;
		token = strtok(NULL, " ");
	}
	
	/* figure out which command it is */
	if(argc > 0)
	{
		cmd = 0;
		while(cmd_commands[cmd] != '\0')
		{
			if(strcmp(argv[0], cmd_commands[cmd])==0)
				break;
			cmd++;
		}

		/* Can we handle this? */
		if(cmd_commands[cmd] != '\0')
		{
			acia_puts("\r\n");

			/* Handle commands */
			switch(cmd)
			{
				case 0:		/* help */
					acia_puts("help - this message\r\n");
					acia_puts("peek <addr> - get value @ <addr> offset\r\n");
					acia_puts("poke <addr> <data> - set register value @ <addr> offset to <data>\r\n");
					break;

				case 1:		/* peek */
					if(argc < 2)
						acia_puts("missing arg\r\n");
					else
					{
						addr = atoi(argv[1]);
						//sprintf(text_buffer,"peek: 0x%04X = 0x%02X\r\n", addr, (unsigned char)(*(unsigned char *)addr));
						//acia_puts(text_buffer);
						acia_puts("peek: 0x");
						utoa(addr, text_buffer, 16);
						acia_puts(text_buffer);
						acia_puts(" = 0x");
						utoa((unsigned char)(*(unsigned char *)addr), text_buffer, 16);
						acia_puts(text_buffer);
						acia_puts("\n\r");
					}
					break;

				case 2:		/* poke */
					if(argc < 3)
						acia_puts("missing arg(s)\r\n");
					else
					{
						addr = atoi(argv[1]);
						data = atoi(argv[2]);
						(unsigned char)(*(unsigned char *)addr) = data;
						//sprintf(text_buffer,"poke: 0x%04X, 0x%02X\r\n", addr, data);
						//acia_puts(text_buffer);
						acia_puts("poke: 0x");
						utoa(addr, text_buffer, 16);
						acia_puts(text_buffer);
						acia_puts(", 0x");
						utoa(data, text_buffer, 16);
						acia_puts(text_buffer);
						acia_puts("\n\r");
					}
					break;

				default:	/* shouldn't get here */
					break;
			}
		}
		else
		{
			acia_puts("err\r\n");
		}
	}	
}

/*
 * initialize the command processor
 */
void cmd_init(void)
{
	cmd_prompt();
}

/*
 * fetch characters and process
 */
void cmd_do(void)
{
	int rx_chr;
	
	if((rx_chr = acia_getc()) != EOF)
	{
		if(rx_chr=='\b')
		{
			if(cmd_widx)
			{
				acia_puts("\b \b"); // erase & backspace
				--cmd_widx;
			}
		}
		else if(rx_chr=='\r')
		{
			acia_puts("\r\n"); // add LF for CR
			cmd_buff[cmd_widx] = 0;	// mark end of command
			cmd_parse();
			cmd_prompt();
		}
		else
		{
			if(cmd_widx<(MAX_CMD_LEN-1))
			{
				// echo and save character in buffer
				acia_putc(rx_chr);
				cmd_buff[cmd_widx] = rx_chr;
				++cmd_widx;
			}
		}
	}
}
