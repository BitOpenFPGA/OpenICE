//
// gb_mist.v
//
// Gameboy for the iCE40 UltraPlus
// 
// Copyright (c) 2015 Till Harbaum <till@harbaum.org> 
// Copyright (c) 2017 David Shah <dave@ds0.me> 
// 
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or 
// (at your option) any later version. 
// 
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License 
// along with this program.  If not, see <http://www.gnu.org/licenses/>. 
//

module gb_mist (
	
	//flash interface
	output spi_csn,
	output spi_sck,
	output spi_mosi,
	input spi_miso,

  input [7:0] joystick;
	// video
   output 			VGA_HS,
   output 			VGA_VS,
   output [1:0] 	VGA_O
);

assign LED = 1'b0;   // light led

wire reset = (reset_cnt != 0);
reg [9:0] reset_cnt;
always @(posedge clk24) begin
	if(!pll_locked)
		reset_cnt <= 10'd1023;
	else
		if(reset_cnt != 0)
			reset_cnt <= reset_cnt - 10'd1;
end

wire cart_ready;
wire gb_reset = (!cart_ready) || reset;

wire card_rd, cart_wr;
wire [7:0] cart_di;

gb_cartridge cart_i (
  .clk(clk4),
  .reset(reset),
  .cart_addr(cart_addr),
  .cart_dout(cart_do),
  .ready(cart_ready),
  
  .spi_sck(spi_sck),
  .spi_csn(spi_csn),
  .spi_mosi(spi_mosi),
  .spi_miso(spi_miso)); 

wire lcd_clkena;
wire [1:0] lcd_data;
wire [1:0] lcd_mode;
wire lcd_on;

wire [15:0] audio_left;
wire [15:0] audio_right;

// the gameboy itself
gb gb (
	.reset	    ( gb_reset        ),
	.clk         ( clk4         ),   // the whole gameboy runs on 4mhnz

	.fast_boot   ( status[2]    ),
	.joystick    ( joystick     ),

	// interface to the "external" game cartridge
	.cart_addr   ( cart_addr   ),
	.cart_rd     ( cart_rd     ),
	.cart_wr     ( cart_wr     ),
	.cart_do     ( cart_do     ),
	.cart_di     ( cart_di     ),

	// audio
	.audio_l 	( audio_left	),
	.audio_r 	( audio_right	),
	
	// interface to the lcd
	.lcd_clkena   ( lcd_clkena ),
	.lcd_data     ( lcd_data   ),
	.lcd_mode     ( lcd_mode   ),
	.lcd_on       ( lcd_on     )
);



// the lcd to vga converter
wire [1:0] video_d;
wire video_hs, video_vs;

lcd lcd_i (
	 .pclk   ( clk8       ),
	 .clk    ( clk4       ),

	 .tint   ( status[1]  ),

	 // serial interface
	 .clkena ( lcd_clkena ),
	 .data   ( lcd_data   ),
	 .mode   ( lcd_mode   ),  // used to detect begin of new lines and frames
	 .on     ( lcd_on     ),
	 
  	 .hs    ( video_hs    ),
	 .vs    ( video_vs    ),
	 .dout     ( video_d     )
);

assign VGA_HS = video_hs;
assign VGA_VS = video_vs;
assign VGA_O = video_d;

				
reg clk4;   // 4.194304 MHz CPU clock and GB pixel clock
always @(posedge clk8) 
	clk4 <= !clk4;

reg clk8;   // 8.388608 MHz VGA pixel clock
always @(posedge clk16) 
	clk8 <= !clk8;

reg clk16;   // 16.777216 MHz
always @(posedge clk32) 
	clk16 <= !clk16;
				

wire clk24;

pll pll_i (
	 .clock_in(clk24),   
	 .clock_out(clk32),  
	 .locked(pll_locked)
);

SB_HFOSC #(
	.CLKHF_DIV("0b01")
) iosc (
	.CLKHFEN(1'b1),
	.CLKHFPU(1'b1),
	.CLKHF(clk24)
);

endmodule
