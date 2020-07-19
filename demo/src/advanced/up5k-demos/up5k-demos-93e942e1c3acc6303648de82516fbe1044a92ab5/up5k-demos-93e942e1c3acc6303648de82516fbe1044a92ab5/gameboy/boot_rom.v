module boot_rom (
	address,
	clock,
	q);

input	[7:0]  address;
input	  clock;
output reg	[7:0]  q;
  
reg [7:0] rom [0:255];
$readmemh(rom, "boot_rom.dat")

always@(posedge clk)
   q <= rom[address];
	 
endmodule