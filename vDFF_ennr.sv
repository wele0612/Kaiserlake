module vDFF_ennr(clk,en,D,Q);
  parameter n=1;
  input clk;
  input en;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  always @(posedge clk)begin
      if(en) begin
          Q <= D;
      end
  end
    
endmodule