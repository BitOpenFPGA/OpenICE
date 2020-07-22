/*
The virtual NES cartridge
At the moment this stores the entire cartridge
in SPRAM, in the future it could stream data from
SQI flash, which is more than fast enough
*/

module cart_mem(
  input clock,
  input reset,
  input sync,
  
  input reload,
  input [3:0] index,
  
  output cart_ready,
  output reg [31:0] flags_out,
  //address into a given section - 0 is the start of CHR and PRG,
  //region is selected using the select lines for maximum flexibility
  //in partitioning
  input [20:0] address,
  
  input prg_sel, chr_sel,
  input ram_sel, //for cart SRAM (NYI)
  
  input rden, wren,
  
  input  [7:0] write_data,
  output [7:0] read_data,
  
  //Flash load interface
  output flash_csn,
  output flash_sck,
  output flash_mosi,
  input flash_miso,

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

  output reg [15:0]  diag
);

//assign diag = flashmem_addr[7:0];
//assign diag = load_addr[7:0];
//assign diag = ~load_write_data[7:0];
//assign diag = spram_read_data[7:0];
//assign diag = {~flash_csn, reset, reload, sync, load_done_pre, flashmem_valid, flashmem_ready};

reg load_done;
initial load_done = 1'b0;

wire cart_ready = load_done;
// Does the image use CHR RAM instead of ROM? (i.e. UNROM or some MMC1)
wire is_chram = flags_out[15];
// Work out whether we're in the SPRAM, used for the main ROM, or the extra 8k SRAM
wire spram_en = prg_sel | (!is_chram && chr_sel);
wire sram_en = ram_sel | (is_chram && chr_sel);

wire [16:0] decoded_address;
assign decoded_address = chr_sel ? {1'b1, address[15:0]} : address[16:0];

reg [16:0] load_addr;
wire [15:0] spram_address = load_done ? decoded_address[16:1] : load_addr[15:0];

wire load_wren;
wire spram_wren = load_done ? (spram_en && wren) : load_wren;
wire [1:0] spram_mask = load_done ? (4'b01 << decoded_address[0]) : 4'b11;
wire [1:0] spram_maskwren = spram_wren ? spram_mask : 4'b00;

wire [15:0] load_write_data;
wire [15:0] spram_write_data = load_done ? {write_data, write_data} : load_write_data;

wire [15:0] spram_read_data;

wire [7:0] csram_read_data;
// Demux the 32-bit memory
assign read_data = sram_en ? csram_read_data : 
    (decoded_address[0] ? spram_read_data[15:8] : spram_read_data[7:0]);

 // The SRAM, used either for PROG_SRAM or CHR_SRAM
generic_ram #(
  .WIDTH(8),
  .WORDS(8192)
) sram_i (
  .clock(clock),
  .reset(reset),
  .address(decoded_address[12:0]), 
  .wren(wren&sram_en), 
  .write_data(write_data), 
  .read_data(csram_read_data)
);

sdram ram(
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
  .clk(clock),
  .init(reset | reload),
  .sync(sync),
  .ds(spram_mask),
  .we(spram_wren),
  .oe(spram_en && !wren),
  .addr({4'b0, spram_address}),
  .din(spram_write_data),
  .dout(spram_read_data)
);

reg [1:0] sdram_written = 0;

reg flashmem_valid;
wire flashmem_ready;
assign load_wren =  sdram_written > 0 && (load_addr != 17'h10000);
wire [23:0] flashmem_addr = (24'h40000 + (index_lat << 18)) | {load_addr, 1'b0};
reg [3:0] index_lat;
reg load_done_pre;
reg [7:0] wait_ctr;

// Flash memory load interface
always @(posedge clock) 
begin
  if (reset == 1'b1) begin
    load_done_pre <= 1'b0;
    load_done <= 1'b0;
    load_addr <= 17'h00000;
    flags_out <= 32'h00000000;
    wait_ctr <= 8'h00;
    index_lat <= 4'h0;
    flashmem_valid <= 1;
  end else begin
    if (reload == 1'b1) begin
      load_done_pre <= 1'b0;
      load_done <= 1'b0;
      load_addr <= 17'h0000;
      flags_out <= 32'h00000000;
      wait_ctr <= 8'h00;
      index_lat <= index;
      flashmem_valid <= 1;
    end else if (!load_done) begin
      if (sdram_written > 0 && sdram_written < 3) begin
        if (sync) sdram_written <= sdram_written + 1;
	if (sdram_written == 2 && sync) begin
          if (load_addr == 17'h10000) begin
            load_done_pre <= 1'b1;
            flags_out <= load_write_data; //last word is mapper flags
          end else begin
            load_addr <= load_addr + 1'b1;
	    flashmem_valid <= 1;
	    sdram_written <= 0;
          end
	end
      end
      if(!load_done_pre) begin
        if (flashmem_ready == 1'b1) begin
	  flashmem_valid <= 0;
	  sdram_written <= 1;
	  diag <= load_write_data;
        end
      end else begin
        if (wait_ctr < 8'hFF)
          wait_ctr <= wait_ctr + 1;
        else
          load_done <= 1'b1;
      end
    end
  end
end

icosoc_flashmem flash_i (
  .clk(clock),
  .reset(reset),
  .valid(flashmem_valid && !load_done),
  .ready(flashmem_ready),
  .addr(flashmem_addr),
  .rdata(load_write_data),

  .spi_cs(flash_csn),
  .spi_sclk(flash_sck),
  .spi_mosi(flash_mosi),
  .spi_miso(flash_miso)
);

endmodule
