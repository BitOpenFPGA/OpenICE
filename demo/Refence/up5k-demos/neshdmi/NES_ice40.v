// Copyright (c) 2012-2013 Ludvig Strigeus
// Copyright (c) 2017 David Shah
// This program is GPL Licensed. See COPYING for the full license.

`timescale 1ns / 1ps

module NES_ice40 (  
	// clock input
  input clock_12,
  output LED0, LED1,
  
  // VGA over HDMI
  output         VGA_CK,
  output         VGA_DE,
  output         VGA_HS, // VGA H_SYNC
  output         VGA_VS, // VGA V_SYNC
  output [ 3:0]  VGA_R, // VGA Red[3:0]
  output [ 3:0]  VGA_G, // VGA Green[3:0]
  output [ 3:0]  VGA_B, // VGA Blue[3:0]
                                                                                                    

  // audio
  output           AUDIO_O,
  
  // joystick
  output joy_strobe, joy_clock,
  input joy_data,
  
  // flashmem
  output flash_sck,
  output flash_csn,
  output flash_mosi,
  input flash_miso,
  
  input buttons

  //output [7:0] leds
  
);
	wire clock;

wire sel_btn;

`ifdef no_io_prim
assign sel_btn = buttons;
`else
//Use SB_IO so we can enable pullup
(* PULLUP_RESISTOR = "10K" *)
SB_IO #(
  .PIN_TYPE(6'b000001),
  .PULLUP(1'b1)
) btns  (
  .PACKAGE_PIN(buttons),
  .D_IN_0(sel_btn)
);
`endif

  wire scandoubler_disable;

  reg clock_locked;
  wire locked_pre;
  always @(posedge clock)
    clock_locked <= locked_pre;
  
  wire [8:0] cycle;
  wire [8:0] scanline;
  wire [15:0] sample;
  wire [5:0] color;
  
  wire load_done;
  wire [21:0] memory_addr;
  wire memory_read_cpu, memory_read_ppu;
  wire memory_write;
  wire [7:0] memory_din_cpu, memory_din_ppu;
  wire [7:0] memory_dout;
  
  wire [31:0] mapper_flags;
  
  pll pll_i (
  	.clock_in(clock_12),
  	.clock_out(clock),
  	.locked(locked_pre)
  );  

  assign VGA_CK = clock;  
  assign LED0 = !memory_addr[0];
  assign LED1 = load_done;
  //assign leds = memory_din_cpu;
  
  wire sys_reset = !clock_locked;
  reg reload;


  reg [2:0] last_pressed;

/*
  reg [3:0] btn_dly;
  always @ ( posedge clock ) begin
    //Detect button release and trigger reload
    btn_dly <= sel_btn[3:0];
    if (sel_btn[3:0] == 4'b1111 && btn_dly != 4'b1111)
      reload <= 1'b1;
    else
      reload <= 1'b0;
    // Button 4 is a "shift"
    if(!sel_btn[0])
      last_pressed <= {!sel_btn[4], 2'b00};
    else if(!sel_btn[1])
      last_pressed <= {!sel_btn[4], 2'b01};
    else if(!sel_btn[2])
      last_pressed <= {!sel_btn[4], 2'b10};
    else if(!sel_btn[3])
      last_pressed <= {!sel_btn[4], 2'b11};
  end
*/

  reg btn_dly;

  always @ (posedge clock ) begin
    btn_dly <= sel_btn;
    if (sel_btn == 1'b1 && btn_dly != 1'b1)
      reload <= 1'b1;
    else 
      reload <= 1'b0;
    
    last_pressed <= 3'b000;
  end

  main_mem mem (
    .clock(clock),
    .reset(sys_reset),
    .reload(reload),
    .index({1'b0, last_pressed}),
    .load_done(load_done),
    .flags_out(mapper_flags),
    //NES interface
    .mem_addr(memory_addr),
    .mem_rd_cpu(memory_read_cpu),
    .mem_rd_ppu(memory_read_ppu),
    .mem_wr(memory_write),
    .mem_q_cpu(memory_din_cpu),
    .mem_q_ppu(memory_din_ppu),
    .mem_d(memory_dout),
    
    //Flash load interface
    .flash_csn(flash_csn),
    .flash_sck(flash_sck),
    .flash_mosi(flash_mosi),
    .flash_miso(flash_miso)
  );
  
  wire reset_nes = !load_done || sys_reset;
  reg [1:0] nes_ce;
  wire run_nes = (nes_ce == 3);	// keep running even when reset, so that the reset can actually do its job!
  
  wire run_nes_g;
  SB_GB ce_buf (
    .USER_SIGNAL_TO_GLOBAL_BUFFER(run_nes),
    .GLOBAL_BUFFER_OUTPUT(run_nes_g)
  );
  
  // NES is clocked at every 4th cycle.
  always @(posedge clock)
    nes_ce <= nes_ce + 1;
  
  wire [31:0] dbgadr;
  wire [1:0] dbgctr;
  
  reg joy_data_sync = 0;
  reg last_joypad_clock;
	
  always @(posedge clock) begin
    if (joy_strobe) begin
      joy_data_sync <= joy_data;
    end

    if (!joy_clock && last_joypad_clock) begin
      joy_data_sync <= joy_data;
    end
    last_joypad_clock <= joy_clock;
  end

  NES nes(clock, reset_nes, run_nes_g,
          mapper_flags,
          sample, color,
          joy_strobe, joy_clock, {3'b0,!joy_data_sync},
          5'b11111,  // enable all channels
          memory_addr,
          memory_read_cpu, memory_din_cpu,
          memory_read_ppu, memory_din_ppu,
          memory_write, memory_dout,
          cycle, scanline,
          dbgadr,
          dbgctr);

/*
reg [5:0] col;
reg [5:0] count;

always @(posedge clock) begin
  if (scanline == 511) begin
    if (count == 0) col <= col + 1;
    count <= count + 1;
  end
end
*/

video video (
	.clk(clock),
		
	.color(color),
	.count_v(scanline),
	.count_h(cycle),
	.mode(1'b0),
	.smoothing(1'b1),
	.scanlines(1'b1),
	.overscan(1'b1),
	.palette(1'b0),
	
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),

        .active(VGA_DE)
	
);

wire audio;
assign AUDIO_O = audio;

sigma_delta_dac sigma_delta_dac (
	.DACout(audio),
	.DACin(sample[15:8]),
	.CLK(clock),
	.RESET(reset_nes),
  .CEN(run_nes)
);



endmodule
