module zpram (
	address,
	clock,
	data,
	wren,
	q);

	input	[7:0]  address;
	input	  clock;
	input	[7:0]  data;
	input	  wren;
	output	reg [7:0]  q;

reg [7:0] ram[0:255];

always @(posedge clock)
begin
	if(wren)
		ram[address] <= data;
	q <= ram[address];
end

endmodule