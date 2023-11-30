module pipeline_3_memwrt (
    input [21:0] control_in,
    input [15:0] data_Rd_in,
    input highbit_shifted_Rm_in,
    input highbit_data_Rn_in,
    input [15:0] result_in,

    input rst,
    input clk,

    output [15:0] result_out,
    output N_out,
    output reg V_out,
    output Z_out, 
    output [21:0] control_out,

    //Connect to ram
    output [15:0] wdata_mem,
    output [8:0] addr_mem,
    output write_mem
);
    wire [15:0] data_Rd;
    wire [2:0] opcode;
    assign opcode=control_out[21:19];
    assign write_mem=(opcode==3'b100);//is opcode STR?

    wire loads=control_out[8];

    vDFF #22 pREG_control (clk,rst,control_in,control_out);
    vDFF #16 pREG_result (clk,rst,result_in,result_out);
    vDFF #16 pREG_data_Rd (clk,rst,data_Rd_in,data_Rd);
    assign wdata_mem=data_Rd;
    assign addr_mem=result_out[8:0];

    wire highbit_shifted_Rm,highbit_data_Rn;
    wire [15:0] result_for_flag;
    vDFF_en #18 flagREG(clk,rst,loads,
        {highbit_shifted_Rm_in,highbit_data_Rn_in,result_in},
        {highbit_shifted_Rm,highbit_data_Rn,result_for_flag});

        assign N_out=result_for_flag[15];
        assign Z_out=~(|result_for_flag);
    
    always @(*) begin
        case ({highbit_data_Rn,highbit_shifted_Rm,result_for_flag[15]})//OVERFLOW
        3'b011,3'b100:  V_out=1'b1; //(+ minus - = -) or (- minus + = +)
        default: V_out=1'b0;
    endcase
    end

endmodule