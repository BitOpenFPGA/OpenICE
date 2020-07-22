// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

module video(
	input  clk,
	input [5:0] color,
	input [8:0] count_h,
	input [8:0] count_v,
	input mode,
	input ypbpr,
	input smoothing,
	input scanlines,
	input overscan,
	input palette,
	

	output       VGA_HS,
	output       VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B,
	
	output osd_visible
);

reg clk2 = 1'b0;
always @(posedge clk) clk2 <= ~clk2;
wire clkv = mode ? clk2 : clk;

wire [5:0] R_out, G_out, B_out;



// NTSC UnsaturatedV6 palette
//see: http://www.firebrandx.com/nespalette.html
/*reg [15:0] pal_unsat_lut[0:63];
initial $readmemh("nes_palette_unsaturatedv6.txt", pal_unsat_lut);*/

// FCEUX palette
reg [15:0] pal_fcelut[0:63];
initial $readmemh("nes_palette_fceux.txt", pal_fcelut);

wire [14:0] pixel = pal_fcelut[color][14:0];
 
// Horizontal and vertical counters
reg [9:0] h, v;
wire hpicture  = (h < 512);             // 512 lines of picture
wire hend = (h == 681);                 // End of line, 682 pixels.
wire vpicture = (v < (480 >> mode));    // 480 lines of picture
wire vend = (v == (523 >> mode));       // End of picture, 524 lines. (Should really be 525 according to NTSC spec)

wire [14:0] doubler_pixel;
wire doubler_sync;

scan_double doubler(clk, pixel,
		            count_v[8],                 // reset_frame
		            (count_h[8:3] == 42),       // reset_line
		            {v[0], h[9] ? 9'd0 : h[8:0] + 9'd1}, // 0-511 for line 1, or 512-1023 for line 2.
		            doubler_pixel);             // pixel is outputted


reg [8:0] old_count_v;
wire sync_frame = (old_count_v == 9'd511) && (count_v == 9'd0);

assign doubler_sync = sync_frame;

always @(posedge clkv) begin
  h <= (hend || (mode ? sync_frame : doubler_sync)) ? 10'd0 : h + 10'd1;
  if(mode ? sync_frame : doubler_sync) v <= 0;
    else if (hend) v <= vend ? 10'd0 : v + 10'd1;

  old_count_v <= count_v;
end

wire [14:0] pixel_v = (!hpicture || !vpicture) ? 15'd0 : mode ? pixel : doubler_pixel;
wire darker = !mode && v[0] && scanlines;

// display overlay to hide overscan area
// based on Mario3, DoubleDragon2, Shadow of the Ninja
wire ol = overscan && ( (h > 512-16) || 
								(h < 20) || 
								(v < (mode ? 6 : 12)) || 
								(v > (mode ? 240-10 : 480-20)) 
							  );

wire  [4:0]   vga_r = ol ? {4'b0, pixel_v[4:4]}   : (darker ? {1'b0, pixel_v[4:1]} : pixel_v[4:0]);
wire  [4:0]   vga_g = ol ? {4'b0, pixel_v[9:9]}   : (darker ? {1'b0, pixel_v[9:6]} : pixel_v[9:5]);
wire  [4:0]   vga_b = ol ? {4'b0, pixel_v[14:14]} : (darker ? {1'b0, pixel_v[14:11]} : pixel_v[14:10]);
wire         sync_h = ((h >= (512 + 23 + (mode ? 18 : 35))) && (h < (512 + 23 + (mode ? 18 : 35) + 82)));
wire         sync_v = ((v >= (mode ? 240 + 5  : 480 + 10))  && (v < (mode ? 240 + 14 : 480 + 12)));


assign VGA_HS = !sync_h;
assign VGA_VS = !sync_v;
assign VGA_R = vga_r[4:1];
assign VGA_G = vga_g[4:1];
assign VGA_B = vga_b[4:1];

endmodule
