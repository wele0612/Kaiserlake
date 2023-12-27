module pipeline_2_execute (
    input [21:0] control_in,
    input [15:0] data_Rm_in,
    input [15:0] data_Rn_in,
    input [15:0] data_Rd_in,
    input [15:0] imm_in,
    input [5:0] inst_type_in,
    input [15:0] delayed_B_in,
    input [2:0] delayed_cond_in,

    input rst,
    input clk,

    output [21:0] control_out,
    output [15:0] data_Rd_out,
    output [15:0] result_out,
    output highbit_shifted_Rm_out,
    output highbit_data_Rn_out,
    output [5:0] inst_type_out,
    output [15:0] delayed_B_out,
    output wire [2:0] delayed_cond_out,

    output loads
);
    wire [15:0] data_Rm,data_Rn,imm;
    vDFF #(22) pREG_control (clk,rst,control_in,control_out);
    vDFF_nr #(16) pREG_data_Rm (clk,data_Rm_in,data_Rm);
    vDFF_nr #(16) pREG_data_Rn (clk,data_Rn_in,data_Rn);
    vDFF_nr #(16) pREG_data_Rd (clk,data_Rd_in,data_Rd_out);

    vDFF_nr #(16) pREG_imm (clk,imm_in,imm);
    vDFF #(6) pREG_inst_type (clk,rst,inst_type_in,inst_type_out);

    vDFF_nr #(16) pREG_delayed_B (clk,delayed_B_in,delayed_B_out);
    vDFF #(3) pREG_delayed_cond (clk,rst,delayed_cond_in,delayed_cond_out);

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