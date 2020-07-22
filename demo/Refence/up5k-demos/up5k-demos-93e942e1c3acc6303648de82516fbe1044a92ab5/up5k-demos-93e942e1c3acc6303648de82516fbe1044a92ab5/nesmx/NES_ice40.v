// Copyright (c) 2012-2013 Ludvig Strigeus
// Copyright (c) 2017 David Shah
// This program is GPL Licensed. See COPYING for the full license.

`timescale 1ns / 1ps

module NES_ice40 (  
  // clock input
  input clock_25,
  output LED0, LED1,
  
  // VGA
  output         VGA_HS, // VGA H_SYNC
  output         VGA_VS, // VGA V_SYNC
  output [ 3:0]  VGA_R, // VGA Red[3:0]
  output [ 3:0]  VGA_G, // VGA Green[3:0]
  output [ 3:0]  VGA_B, // VGA Blue[3:0]                                                                                                  
  inout      [15:0] sd_data,    // 16 bit bidirectional data bus
  output     [10:0] sd_addr,    // 11 bit multiplexed address bus
  output     [1:0]  sd_dqm,     // two byte masks
  output     [0:0]  sd_ba,      // two banks
  output            sd_cs,      // a single chip select
  output            sd_we,      // write enable
  output            sd_ras,     // row address select
  output            sd_cas,     // columns address select
  output            sd_cke,     // clock enable
  output            sd_clk,     // sdram clock

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
  
  input buttons,

  output reg [15:0] diag
  
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
  	.clock_in(clock_25),
  	.clock_out(clock),
  	.locked(locked_pre)
  );  
 
   // Use SB_IO for tristate sd_data
  wire [15:0] sd_data_in;
  reg  [15:0] sd_data_out;
  reg         sd_data_dir;

  SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 0)
  ) ram [15:0] (
    .PACKAGE_PIN(sd_data),
    .OUTPUT_ENABLE(sd_data_dir),
    .D_OUT_0(sd_data_out),
    .D_IN_0(sd_data_in)
  );

  assign LED0 = !reload;
  assign LED1 = !load_done;
  //assign diag = memory_din_cpu;
  
  reg reload;
  reg [12:0] reset_count;
  wire sys_reset = !(&reset_count);

  always @(posedge clock) begin
    if (clock_locked && sys_reset) reset_count <= reset_count + 1;
  end

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
    //if (memory_addr[15:0] == 1) diag = sd_data_in;
    btn_dly <= sel_btn;
    if (sel_btn == 1'b1 && btn_dly != 1'b1)
      reload <= 1'b1;
    else 
      reload <= 1'b0;
    
    last_pressed <= 3'b000;
  end

  assign sd_clk = clock;
  assign sd_cke = 1;
  
  reg [15:0] diag1;

  main_mem mem (
    .clock(clock),
    .reset(sys_reset),
    .sync(run_nes_g),
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
    .flash_miso(flash_miso),

    // SDRAM
    .sd_data_in(sd_data_in),
    .sd_data_out(sd_data_out),
    .sd_data_dir(sd_data_dir),
    .sd_addr(sd_addr),
    .sd_dqm(sd_dqm),
    .sd_ba(sd_ba),
    .sd_cs(sd_cs),
    .sd_we(sd_we),
    .sd_ras(sd_ras),
    .sd_cas(sd_cas),
    .diag(diag)
  );
  
  wire reset_nes = !load_done || sys_reset;
  reg [2:0] nes_ce;
  wire run_nes = (nes_ce == 7);	// keep running even when reset, so that the reset can actually do its job!
  
  wire run_nes_g;
  SB_GB ce_buf (
    .USER_SIGNAL_TO_GLOBAL_BUFFER(run_nes),
    .GLOBAL_BUFFER_OUTPUT(run_nes_g)
  );
 
  reg clk21;

  // NES is clocked at every 4th cycle.
  always @(posedge clock) begin
    nes_ce <= nes_ce + 1;
    clk21 <= ~clk21;
  end
  
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
	.clk(clk21),
		
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
	.VGA_B(VGA_B)
	
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
