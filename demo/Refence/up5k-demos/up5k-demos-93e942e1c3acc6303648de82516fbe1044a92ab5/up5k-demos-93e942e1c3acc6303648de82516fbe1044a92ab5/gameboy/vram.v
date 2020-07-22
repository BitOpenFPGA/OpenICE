module vram (
	address,
	clock,
	data,
	wren,
	q);

	input	[12:0]  address;
	input	  clock;
	input	[7:0]  data;
	input	  wren;
	output [7:0]  q;
	
`ifdef vram_use_spram
	SB_SPRAM256KA spram_i
	  (
	    .ADDRESS({1'b0, address}),
	    .DATAIN({8'b0, data}),
	    .MASKWREN(4'b0011),
	    .WREN(wren),
	    .CHIPSELECT(1'b1),
	    .CLOCK(clk),
	    .STANDBY(1'b0),
	    .SLEEP(1'b0),
	    .POWEROFF(1'b1),
	    .DATAOUT(q)
	  );

`else
	reg [7:0] ram[0:8191];
	reg [7:0] q_pre;
	always @(posedge clock)
	begin
		if(wren)
			ram[address] <= data;
		q_pre <= ram[address];
	end
	assign q = q_pre;
`endif