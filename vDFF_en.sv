module vDFF_en(clk,rst,en,D,Q);
  parameter n=1;
  input clk;
  input rst;
  input en;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;

  always @(posedge clk)begin
    if(rst) begin
        Q <= 0;
    end else begin
        if(en) begin
            Q <= D;
        end
    end
  end
    
endmodule