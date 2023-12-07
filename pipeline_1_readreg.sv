module pipeline_1_readreg (
    input [21:0] control_in,
    input [2:0] num_Rm_in,
    input [2:0] num_Rn_in,
    input [2:0] num_Rd_in,
    input [15:0] imm_in,
    input [2:0] used_RmRnRd_in,
    input [5:0] inst_type_in,
    input [15:0] delayed_B_in,
    input [2:0] delayed_cond_in,

    input rst,
    input clk,
    input update,

    output wire [21:0] control_out,
    output wire [2:0] num_Rm_out,
    output wire [2:0] num_Rn_out,
    output wire [2:0] num_Rd_out,
    output wire [15:0] imm_out,
    output wire [2:0] used_RmRnRd_out,
    output wire [5:0] inst_type_out,
    output wire [15:0] delayed_B_out,
    output wire [2:0] delayed_cond_out,

    output wire loads
);
    wire [15:0] imm;
    //For BL and BLX
    assign imm_out=(inst_type_out[2]||inst_type_out[4])?{8'b0,delayed_B_out[7:0]}:imm;
    //BL or BLX: replace imm with PC+1

    vDFF_en #22 pREG_control (clk,rst,update,control_in,control_out); 
    vDFF_ennr #3 pREG_num_Rm (clk,update,num_Rm_in,num_Rm_out); //instantiate "reg nums_a"
    vDFF_ennr #3 pREG_num_Rn (clk,update,num_Rn_in,num_Rn_out); //instantiate "reg nums_b"
    vDFF_ennr #3 pREG_num_Rd (clk,update,num_Rd_in,num_Rd_out); //注释没活儿可以不写
    vDFF_ennr #16 pREG_imm (clk,update,imm_in,imm); //instantiate "imm"
    vDFF_en #3 pREG_used_RmRnRd (clk,rst,update,used_RmRnRd_in,used_RmRnRd_out);
    vDFF_en #6 pREG_inst_type (clk,rst,update,inst_type_in,inst_type_out);

    vDFF_ennr #16 pREG_delayed_B (clk,update,delayed_B_in,delayed_B_out);
    vDFF_en #3 pREG_delayed_cond (clk,rst,update,delayed_cond_in,delayed_cond_out);

    assign loads=control_out[8];

endmodule