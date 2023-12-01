module pipeline_1_readreg (
    input [21:0] control_in,
    input [2:0] num_Rm_in,
    input [2:0] num_Rn_in,
    input [2:0] num_Rd_in,
    input [15:0] imm_in,

    input rst,
    input clk,
    input update,

    output wire [21:0] control_out,
    output wire [2:0] num_Rm_out,
    output wire [2:0] num_Rn_out,
    output wire [2:0] num_Rd_out,
    output wire [15:0] imm_out,

    output wire [15:0] data_Rm_out,
    output wire [15:0] data_Rn_out,
    output wire [15:0] data_Rd_out,

    output wire loads,
    
    //wires about write 
    input [2:0] num_write0_in,
    input [2:0] num_write1_in,
    input write0_in,
    input write1_in,
    input [15:0] data_write0_in,
    input [15:0] data_write1_in
);
    vDFF_en #22 pREG_control (clk,rst,update,control_in,control_out); //instantiate "control",    USE OF PARAMETER WILL CAUSE ERRORS!!!
    vDFF_en #3 pREG_num_Rm (clk,rst,update,num_Rm_in,num_Rm_out); //instantiate "reg nums_a"
    vDFF_en #3 pREG_num_Rn (clk,rst,update,num_Rn_in,num_Rn_out); //instantiate "reg nums_b"
    vDFF_en #3 pREG_num_Rd (clk,rst,update,num_Rd_in,num_Rd_out);
    vDFF_en #16 pREG_imm (clk,rst,update,imm_in,imm_out); //instantiate "imm"

    regfile REGFILE (
        .num_read0_in(num_Rm_out),//Rm
        .num_read1_in(num_Rn_out),//Rn
        .num_read2_in(num_Rd_out),//Rd

        .data_read0_out(data_Rm_out),
        .data_read1_out(data_Rn_out),
        .data_read2_out(data_Rd_out),

        //write1 has higher priority, implemented inside regfile
        .num_write0_in(num_write0_in),
        .num_write1_in(num_write1_in),

        .write0(write0_in),
        .write1(write1_in),  

        .data_write0_in(data_write0_in),
        .data_write1_in(data_write1_in),

        .clk(clk)
    );

    assign loads=control_out[8];

endmodule