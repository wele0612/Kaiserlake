module dprom_sclk
(
	clk,
	addr_a,
	q_a,

	addr_b,
	q_b
);
	input clk;

	input [7:0] addr_a;
	output reg [15:0] q_a;
	
	input [7:0] addr_b;
	output reg [15:0] q_b;
	

	parameter filename = "data.txt";
	// Declare the RAM variable
	reg [15:0] mem[255:0];

	initial $readmemb(filename, mem);
	
	// Port A
	always @ (posedge clk)
	begin
		q_a <= mem[addr_a];
	end
	
	// Port B
	always @ (posedge clk)
	begin
		q_b <= mem[addr_b];
	end
endmodule