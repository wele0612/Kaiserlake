module pipeline_2_execute (
    input [21:0] control_in,
    input [2:0] num_Rm_in,
    input [2:0] num_Rn_in,
    input [2:0] num_Rd_in,
    input [15:0] data_Rm_in,
    input [15:0] data_Rn_in,
    input [15:0] data_Rd_in,
    input [15:0] imm_in,

    input rst,
    input clk,

    output [21:0] control_out,
    output [2:0] num_Rm_out,
    output [2:0] num_Rn_out,
    output [2:0] num_Rd_out,
    output [15:0] data_Rd_out,
    output [15:0] result_out,
    output highbit_shifted_Rm_out,
    output highbit_data_Rn_out,

    output loads
);
    wire [15:0] data_Rm,data_Rn,imm;
    vDFF #22 pREG_control (clk,rst,control_in,control_out);
    vDFF #3 pREG_num_Rm (clk,rst,num_Rm_in,num_Rm_out);
    vDFF #3 pREG_num_Rn (clk,rst,num_Rn_in,num_Rn_out);
    vDFF #3 pREG_num_Rd (clk,rst,num_Rd_in,num_Rd_out);
    vDFF #16 pREG_data_Rm (clk,rst,data_Rm_in,data_Rm);
    vDFF #16 pREG_data_Rn (clk,rst,data_Rn_in,data_Rn);
    vDFF #16 pREG_data_Rd (clk,rst,data_Rd_in,data_Rd_out);

    vDFF #16 pREG_imm (clk,rst,imm_in,imm);

    wire [1:0] ALUop,shift;
    wire asel,bsel;
    assign {asel,bsel,loads,ALUop,shift}={control_out[10:4]};   //control signal to ports

    wire [15:0] data_Rm_shifted;
    shifter SHIFTER(
        .in(data_Rm),
        .shift(shift),
        .sout(data_Rm_shifted)
    );

    pipelineALU pALU(
        .Ain(bsel?imm:data_Rn),
        .Bin(asel?16'b0:data_Rm_shifted),
        .ALUop(ALUop),
        .out(result_out)
    );

    assign highbit_data_Rn_out=data_Rn[15];
    assign highbit_shifted_Rm_out=data_Rm_shifted[15];
endmodule

module pipelineALU(Ain,Bin,ALUop,out);
input [15:0] Ain, Bin;
input [1:0] ALUop;
output reg [15:0] out;

always @(*) begin
    case (ALUop)
        2'b00:  out=Ain+Bin;
        2'b01:  out=Ain-Bin;
        2'b10:  out=Ain&Bin;
        2'b11:  out=~Bin;
        default: out=Ain+Bin;
    endcase
    /*
    Z=~(|out);//Is ZERO
    case ({Ain[15],Bin[15],out[15]})//OVERFLOW
        3'b011,3'b100:  V=1'b1; //(+ minus - = -) or (- minus + = +)
        default: V=1'b0;
    endcase
    N=out[15];//Is NEGATIVE
    */
end

endmodule

module shifter(in,shift,sout);
parameter n = 16;
input [15:0] in;
input [1:0] shift;
output reg [15:0] sout;

always @(*) begin
    case (shift)
        2'b00:  sout=in;
        2'b01:  sout=in<<1; 
        2'b10:  sout=in>>1;
        2'b11:  begin
            sout=in>>1;
            sout={in[15],sout[14:0]};
        end
        default: sout=in;
    endcase
end

endmodule