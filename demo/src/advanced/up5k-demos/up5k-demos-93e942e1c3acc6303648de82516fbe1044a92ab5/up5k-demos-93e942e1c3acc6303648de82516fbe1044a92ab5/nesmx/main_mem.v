/*
This memory device contains both system memory
and cartridge data.
*/

module main_mem(
  input clock, reset,

  input sync,  
  input reload,
  input [3:0] index,
  
  output load_done,
  output [31:0] flags_out,
  //NES interface
  input [21:0] mem_addr,
  input mem_rd_cpu, mem_rd_ppu,
  input mem_wr,
  output reg [7:0] mem_q_cpu, mem_q_ppu,
  input [7:0] mem_d,
  
  //Flash load interface
  output flash_csn,
  output flash_sck,
  output flash_mosi,
  input flash_miso,

  // SDRAM
  input      [15:0] sd_data_in, // 16 bit bidirectional data bus
  output     [15:0] sd_data_out,
  output            sd_data_dir,
  output     [10:0] sd_addr,    // 11 bit multiplexed address bus
  output     [1:0]  sd_dqm,     // two byte masks
  output     [0:0]  sd_ba,      // two banks
  output            sd_cs,      // a single chip select
  output            sd_we,      // write enable
  output            sd_ras,     // row address select
  output            sd_cas,     // columns address select
  output            sd_cke,     // clock enable
  output            sd_clk,     // sdram clock

  output      [15:0] diag
);
  
// Compress the 4MB logical address space to our limited available space
// In the future a more sophisticated memory system will keep games in
// SQI flash to expand the space available

// Also may consider changing this based on mapper to make the most
// of limited memory

wire prgrom_en, chrrom_en, vram_en, cpuram_en, cartram_en;

// Mapping
// 0... : PRG       : lower 64kB SPRAM
// 10.. : CHR       : upper 64kB SPRAM
// 1100 : CHR-VRAM  : dedicated 2kB RAM
// 1110 : CPU-RAM   : dedicated 2kB RAM
// 1111 : CART-RAM  : dedicated 2kB RAM

assign prgrom_en    = !mem_addr[21];
assign chrrom_en    = mem_addr[21] & !mem_addr[20];
assign vram_en      = mem_addr[21] & mem_addr[20] & !mem_addr[19] & !mem_addr[18];
assign cpuram_en    = mem_addr[21] & mem_addr[20] & mem_addr[19] & !mem_addr[18];
assign cartram_en   = mem_addr[21] & mem_addr[20] & mem_addr[19] & mem_addr[18];

wire [20:0] segment_addr = prgrom_en ? mem_addr[20:0] : (chrrom_en ? {1'b0, mem_addr[19:0]} : {3'b0, mem_addr[17:0]});

wire [7:0] cpuram_read_data, vram_read_data, cart_read_data;
wire rden = mem_rd_cpu | mem_rd_ppu;

always@(posedge clock or posedge reset)
begin
  if (reset == 1'b1) begin
    mem_q_cpu <= 0;
    mem_q_ppu <= 0;
  end else begin
    if (mem_rd_cpu)
      mem_q_cpu <= cpuram_en ? cpuram_read_data : (vram_en ? vram_read_data : cart_read_data);
    if (mem_rd_ppu)
      mem_q_ppu <= cpuram_en ? cpuram_read_data : (vram_en ? vram_read_data : cart_read_data);
  end;
end

cart_mem cart_i (
  .clock(clock),
  .reset(reset),
  .sync(sync),
  .reload(reload),
  .index(index),
  .cart_ready(load_done),
  .flags_out(flags_out),
  .address(segment_addr),
  .prg_sel(prgrom_en),
  .chr_sel(chrrom_en),
  .ram_sel(cartram_en),
  .rden(rden),
  .wren(mem_wr),
  .write_data(mem_d),
  .read_data(cart_read_data),
  
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

generic_ram #(
  .WIDTH(8),
  .WORDS(2048)
) cpuram_i (
  .clock(clock),
  .reset(reset),
  .address(segment_addr[10:0]), 
  .wren(mem_wr&cpuram_en), 
  .write_data(mem_d), 
  .read_data(cpuram_read_data)
);

generic_ram #(
  .WIDTH(8),
  .WORDS(2048)
) vram_i (
  .clock(clock),
  .reset(reset),
  .address(segment_addr[10:0]), 
  .wren(mem_wr&vram_en), 
  .write_data(mem_d), 
  .read_data(vram_read_data)
);

endmodule
