module pipeline_assembly (
    input [15:0] IR_in,
    input [7:0] PC_in,

    input clk,rst,
    input [4:1] rst_p,//S0 need no reset
    input update_1in,

    //to outside REGFILE
    input [15:0] data_Rm_2in,
    input [15:0] data_Rn_2in,
    input [15:0] data_Rd_2in,

    output [2:0] num_Rm_1out,
    output [2:0] num_Rn_1out,
    output [2:0] num_Rd_1out,
    //to forwarding
    output [15:0] result_2out_3in,
    output [15:0] result_3out_4in,
    output [2:0] writenum_2out,
    output [2:0] writenum_3out,
    output write_2out,
    output write_3out,

    output N_out,
    output V_out,
    output Z_out,

    output [15:0] writeback_data_out,
    output [2:0] writenum_out,
    output write_out,
    
    input [15:0] rdata_mem,
    output [15:0] wdata_mem,
    output [8:0] addr_mem,
    output write_mem,

    output [2:0] used_RmRnRd_2out;

    //loads
    output loads_1out,
    output loads_2out
);
    wire [21:0] control_0out_1in,control_1out_2in,control_2out_3in,control_3out_4in;
    wire [2:0] num_Rm_0out_1in;
    wire [2:0] num_Rn_0out_1in;
    wire [2:0] num_Rd_0out_1in;
    wire [15:0] imm_0out_1in,imm_1out_2in;
    wire [15:0] data_Rd_2out_3in;
    wire [2:0] used_RmRnRd_0out_1in;

    wire highbit_shifted_Rm_2out_3in;
    wire highbit_data_Rn_2out_3in;

    assign write_2out=control_2out_3in[3];
    assign writenum_2out=control_2out_3in[2:0];
    assign write_3out=control_3out_4in[3];
    assign writenum_3out=control_3out_4in[2:0];

    pipeline_0_decode S0_DECODE(
        .IR_in(IR_in),
        .PC(PC_in),

        .control_out(control_0out_1in),
        .num_Rm(num_Rm_0out_1in),
        .num_Rn(num_Rn_0out_1in),
        .num_Rd(num_Rd_0out_1in),
        .sximm(imm_0out_1in),
        .used_RmRnRd_out(used_RmRnRd_0out_1in)
    );

    pipeline_1_readreg S1_READREG(
        .control_in(control_0out_1in),
        .num_Rm_in(num_Rm_0out_1in),
        .num_Rn_in(num_Rn_0out_1in),
        .num_Rd_in(num_Rd_0out_1in),
        .imm_in(imm_0out_1in),
        .used_RmRnRd_in(used_RmRnRd_0out_1in),

        .rst(rst|rst_p[1]),
        .clk(clk),
        .update(update_1in),

        .control_out(control_1out_2in),
        .num_Rm_out(num_Rm_1out),
        .num_Rn_out(num_Rn_1out),
        .num_Rd_out(num_Rd_1out),
        .imm_out(imm_1out_2in),
        .used_RmRnRd_out(used_RmRnRd_2out),

        .loads(loads_1out)
    );

    pipeline_2_execute S2_EXECUTE(
        .control_in(control_1out_2in),
        .data_Rm_in(data_Rm_2in),
        .data_Rn_in(data_Rn_2in),
        .data_Rd_in(data_Rd_2in),
        .imm_in(imm_1out_2in),

        .rst(rst|rst_p[2]),
        .clk(clk),

        .control_out(control_2out_3in),
        .data_Rd_out(data_Rd_2out_3in),
        .result_out(result_2out_3in),
        .highbit_shifted_Rm_out(highbit_shifted_Rm_2out_3in),
        .highbit_data_Rn_out(highbit_data_Rn_2out_3in),

        .loads(loads_2out)
    );

    pipeline_3_memwrt S3_MEMWRT(
        .control_in(control_2out_3in),
        .data_Rd_in(data_Rd_2out_3in),
        .highbit_shifted_Rm_in(highbit_shifted_Rm_2out_3in),
        .highbit_data_Rn_in(highbit_data_Rn_2out_3in),
        .result_in(result_2out_3in),

        .rst(rst|rst_p[3]),
        .clk(clk),

        .result_out(result_3out_4in),
        .N_out(N_out),
        .V_out(V_out),
        .Z_out(Z_out),
        .control_out(control_3out_4in),

        .wdata_mem(wdata_mem),
        .addr_mem(addr_mem),
        .write_mem(write_mem)
    );

    pipeline_4_regwrt S4_REGWRT(
        .control_in(control_3out_4in),
        .rdata_in(rdata_mem),
        .result_in(result_3out_4in),

        .rst(rst|rst_p[4]),
        .clk(clk),

        .writeback_data_out(writeback_data_out),
        .writenum_out(writenum_out),
        .write_out(write_out)
    );

    
endmodule
