/*
Cartridge memory with SPI loader
*/
module gb_cartridge (
  input clk,
  input reset,
  input [15:0] cart_addr,
  output [7:0] cart_dout,
  output ready,
  
  output spi_sck,
  output spi_csn,
  output spi_mosi,
  input spi_miso);

reg load_done;
initial load_done = 1'b0;
assign ready = load_done;

wire [13:0] mem_addr;
wire [31:0] mem_din;
wire [31:0] mem_dout;
wire mem_wren; 

SB_SPRAM256KA spram_0
  (
    .ADDRESS(mem_addr),
    .DATAIN(mem_din[15:0]),
    .MASKWREN(4'b1111),
    .WREN(wren),
    .CHIPSELECT(1'b1),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT(mem_dout[15:0])
  );

SB_SPRAM256KA spram_1
  (
    .ADDRESS(mem_addr),
    .DATAIN(mem_din[31:16]),
    .MASKWREN(4'b1111),
    .WREN(wren),
    .CHIPSELECT(1'b1),
    .CLOCK(clk),
    .STANDBY(1'b0),
    .SLEEP(1'b0),
    .POWEROFF(1'b1),
    .DATAOUT(mem_dout[31:16])
  );
  
reg  [13:0] load_addr;
wire [31:0] load_data;
wire load_wren;

assign mem_addr  = load_done ? cart_addr[14:1] : load_addr;
assign mem_din   = load_data;
assign mem_wren  = load_done ? 1'b0 : load_wren;
assign cart_dout = cart_addr[1] ? (cart_addr[0] ? mem_dout[31:24] : mem_dout[23:16]) :
                                  (cart_addr[0] ? mem_dout[15:08] : mem_dout[07:00]);

wire flashmem_valid = !load_done;
wire flashmem_ready;
assign load_wren =  flashmem_ready;
wire flashmem_rstn = !reset;
wire [23:0] flashmem_addr = 24'h100000 | {load_addr, 2'b00};

always @(posedge reset or posedge clk) 
begin
  if (reset == 1'b1) begin
    load_done <= 1'b0;
    load_addr <= 14'h0000;
  end else begin
    if (flashmem_ready == 1'b1) begin
      if (load_addr == 14'h3FFF) begin
        load_done <= 1'b1;
      end else begin
        load_addr <= load_addr + 1'b1;
      end;
    end
  end
end

module icosoc_flashmem (
	.clk(clk)
  .resetn(resetn),
  .valid(flashmem_valid),
  .ready(flashmem_ready),
  .addr(flashmem_addr),
  .rdata(load_data),


	.spi_cs(spi_csn),
	.spi_sclk(spi_sck),
	.spi_mosi(spi_mosi),
	.spi_miso(spi_miso)
);

endmodule