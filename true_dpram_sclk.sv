module true_dpram_sclk
(
	clk,
	ena,
	data_a,addr_a,we_a,
	q_a

	,data_b,addr_b,we_b,
	q_b


);
	input clk;
	input ena;

	input [15:0] data_a;
	input [7:0] addr_a;
	input we_a;
	output reg [15:0] q_a;
	
	input [15:0] data_b;
	input [7:0] addr_b;
	input we_b;
	output reg [15:0] q_b;
	

	parameter filename = "data.txt";
	// Declare the RAM variable
	reg [15:0] mem[255:0];

	initial $readmemb(filename, mem);
	
	// Port A
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			mem[addr_a] = data_a;
		end
		if(ena)
		q_a <= mem[addr_a];
	end
	
	// Port B
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			mem[addr_b] = data_b;
		end
		if(ena)
		q_b <= mem[addr_b];
	end
endmodule