module pipeline_1_readreg (
    input [21:0] control_in,
    input [2:0] num_Rm_in,
    input [2:0] num_Rn_in,
    input [2:0] num_Rd_in,
    input [15:0] imm_in,
    input [2:0] used_RmRnRd_in,

    input rst,
    input clk,
    input update,

    output wire [21:0] control_out,
    output wire [2:0] num_Rm_out,
    output wire [2:0] num_Rn_out,
    output wire [2:0] num_Rd_out,
    output wire [15:0] imm_out,
    output wire [2:0] used_RmRnRd_out,

    output wire loads
);
    vDFF_en #22 pREG_control (clk,rst,update,control_in,control_out); 
    vDFF_en #3 pREG_num_Rm (clk,rst,update,num_Rm_in,num_Rm_out); //instantiate "reg nums_a"
    vDFF_en #3 pREG_num_Rn (clk,rst,update,num_Rn_in,num_Rn_out); //instantiate "reg nums_b"
    vDFF_en #3 pREG_num_Rd (clk,rst,update,num_Rd_in,num_Rd_out); //注释没活儿可以不写
    vDFF_en #16 pREG_imm (clk,rst,update,imm_in,imm_out); //instantiate "imm"
    vDFF_en #3 pREG_used_RmRnRd (clk,rst,update,used_RmRnRd_in,used_RmRnRd_out);

    assign loads=control_out[8];

endmodule