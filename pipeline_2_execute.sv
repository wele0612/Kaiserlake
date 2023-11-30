module pipeline_2_execute (
    control_in,Rm,Rn,Rram,imm_in,N_prev,V_prev,Z_prev,read_num_m,read_num_n,read_num_ram,rst,clk,
    control_out,read_num_m_out,read_num_n_out,read_num_ram_out,N,V,Z,result,Rram_out
);
    parameter control_width=22;
    input [control_width-1:0] control_in;
    input [15:0] Rm;
    input [15:0] Rn;
    input [15:0] Rram;
    input [15:0] imm_in;
    input [2:0] read_num_m;
    input [2:0] read_num_n;
    input [2:0] read_num_ram;
    input N_prev;
    input V_prev;
    input Z_prev;
    input rst;
    input clk;

    output [control_width-1:0] control_out;
    output N;
    output V;
    output Z;
    output [2:0] read_num_m_out;
    output [2:0] read_num_n_out;
    output [2:0] read_num_ram_out;
    output [15:0] result;
    output [15:0] Rram_out;

    wire [15:0] shift_in;   //wire connect to "shift" module 
    wire [15:0] reg_Rn_out;     //wire connect to lower_mux input "Rm"
    wire [15:0] imm_out;       //wire connect to lower_mux input "imm"
    wire [15:0] shift_uppermux_in;     //wire connect to upper mux input
    wire [15:0] ALU_Rn,ALU_Rm;
    wire [1:0] ALUop,shift;
    wire asel,bsel,loads;
    wire N_new,V_new,Z_new;
    
    assign {asel,bsel,loads,ALUop,shift}={control_out[10:4]};   //control signal to ports
    
    vDFF #3 readnum_m (clk,rst,read_num_m,read_num_m_out);//registor number
    vDFF #3 readnum_n (clk,rst,read_num_n,read_num_n_out);
    vDFF #3 readnum_ram (clk,rst,read_num_ram,read_num_ram_out);

    vDFF #22 control (clk,rst,control_in,control_out);  //instaniation of  "control"

    vDFF #16 imm (clk,rst,imm_in,imm_out);      //instantiation of "imm"

    vDFF #16 regnumber_m(clk,rst,Rm,shift_in);
    shifter shifter (shift_in,shift,shift_uppermux_in); //instantiation of shifter

    vDFF #16 regnumber_n(clk,rst,Rn,reg_Rn_out);    //instaniation of  "reg value"
    vDFF #16 regnumber_ram(clk,rst,Rram,Rram_out);


/*
    assign ALU_Rn= bsel ? 16'b0 : reg_Rn_out;    //instantiation of two muxs
    assign ALU_Rm= asel ? imm_out : shift_uppermux_in;*/

    assign ALU_Rm=asel?16'b0:shift_uppermux_in;
    assign ALU_Rn=bsel?imm_out:reg_Rn_out;
    //asel controls Bin=Rn; bsel control Ain=Rm

    piplineALU pALU(.Ain(ALU_Rn),
                    .Bin(ALU_Rm),
                    .ALUop(ALUop),
                    .out(result),
                    .Z(Z_new),
                    .V(V_new),
                    .N(N_new));

    assign Z=loads?Z_new:Z_prev;
    assign V=loads?V_new:V_prev;
    assign N=loads?N_new:N_prev;


endmodule

module piplineALU(Ain,Bin,ALUop,out,Z,V,N);
input [15:0] Ain, Bin;
input [1:0] ALUop;
output reg [15:0] out;
output reg Z,V,N;

always @(*) begin
    case (ALUop)
        2'b00:  out=Ain+Bin;
        2'b01:  out=Ain-Bin;
        2'b10:  out=Ain&Bin;
        2'b11:  out=~Bin;
        default: out=Ain+Bin;
    endcase
    Z=~(|out);//Is ZERO
    case ({Ain[15],Bin[15],out[15]})//OVERFLOW
        3'b011,3'b100:  V=1'b1; //(+ minus - = -) or (- minus + = +)
        default: V=1'b0;
    endcase
    N=out[15];//Is NEGATIVE
end

endmodule