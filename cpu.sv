module cpu (

    input clk,
    input rst,
    
    input [15:0] p0_DM_rdata,
    output [8:0] p0_DM_maddr,
    output [15:0] p0_DM_wdata,
    output p0_DM_write_mem,

    input [15:0] p1_DM_rdata,
    output [8:0] p1_DM_maddr,
    output [15:0] p1_DM_wdata,
    output p1_DM_write_mem,

    input [15:0] p0_IM_rdata,
    output [8:0] p0_IM_maddr,
    input [15:0] p1_IM_rdata,
    output [8:0] p1_IM_maddr
);
    //-------Pipline 0 signal declare---------------
    wire [2:0] p0_num_Rm_1out,p0_num_Rn_1out,p0_num_Rd_1out;
    wire [15:0] p0_data_Rm_regout,p0_data_Rn_regout,p0_data_Rd_regout;
    wire [15:0] p0_data_Rm_2in,p0_data_Rn_2in,p0_data_Rd_2in;

    wire [15:0] p0_result_2out_3in,p0_result_3out_4in;

    wire [15:0] p0_writeback_data_out;
    wire [2:0] p0_writenum_out;
    wire p0_write_out;

    wire [2:0] p0_writenum_1out,p0_writenum_2out,p0_writenum_3out;
    wire p0_write_1out,p0_write_2out,p0_write_3out;
    wire [2:0] p0_used_RmRnRd_1out;
    wire [5:0] p0S1_inst_type,p0S2_inst_type,p0S3_inst_type;

    wire p0_update_1;
    wire [4:1] p0_rst_HCU;

    //To BGU
    wire p0_N,p0_V,p0_Z;
    wire p0_loads_1out,p0_loads_2out;
    //---------------------------------------------

    //-------Pipline 1 signal declare---------------
    wire [2:0] p1_num_Rm_1out,p1_num_Rn_1out,p1_num_Rd_1out;
    wire [15:0] p1_data_Rm_regout,p1_data_Rn_regout,p1_data_Rd_regout;
    wire [15:0] p1_data_Rm_2in,p1_data_Rn_2in,p1_data_Rd_2in;

    wire [15:0] p1_result_2out_3in,p1_result_3out_4in;

    wire [15:0] p1_writeback_data_out;
    wire [2:0] p1_writenum_out;
    wire p1_write_out;

    wire [2:0] p1_writenum_1out,p1_writenum_2out,p1_writenum_3out;
    wire p1_write_1out,p1_write_2out,p1_write_3out;
    wire [2:0] p1_used_RmRnRd_1out;
    wire [5:0] p1S1_inst_type,p1S2_inst_type,p1S3_inst_type;

    wire p1_update_1;
    wire [4:1] p1_rst_HCU;

    //To BGU
    wire p1_N,p1_V,p1_Z;
    wire p1_loads_1out,p1_loads_2out;
    //---------------------------------------------
    //General contraol & branching signals
    wire fetch_next;

    wire [15:0] p0_IR_in;
    wire [15:0] p1_IR_in;
    wire [7:0] p0_PC_in;
    wire [7:0] p1_PC_in;

    //-----------------PC--------------------------
    wire [8:0] PC_curr,PC_next;
    vDFF #9 REG_PC(clk,rst,PC_next,PC_curr);

    assign p0_IM_maddr={{1'b0},PC_curr[7:1],{1'b0}};
    assign p1_IM_maddr={{1'b0},PC_curr[7:1],{1'b1}};

    assign p0_PC_in=p0_IM_maddr;
    assign p1_PC_in=p0_IM_maddr;
    assign p0_IR_in=p0_IM_rdata;
    assign p1_IR_in=p1_IM_rdata;
    //----------------BGU--------------------------
    BGU pBGU(
        .PC(PC_curr),
        .fetch_next_in(fetch_next),

        .PC_next(PC_next)
    );

    data_forward p0_data_Rm_forward(
        .data_reg_in(p0_data_Rm_regout),
        .num_reg_in(p0_num_Rm_1out),

        .data_m1_in(p1_result_2out_3in),
        .data_m2_in(p0_result_2out_3in),
        .data_m3_in(p1_result_3out_4in),
        .data_m4_in(p0_result_3out_4in),
        .data_m5_in(p1_writeback_data_out),
        .data_m6_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_2out),
        .num_m2_in(p0_writenum_2out),
        .num_m3_in(p1_writenum_3out),
        .num_m4_in(p0_writenum_3out),
        .num_m5_in(p1_writenum_out),
        .num_m6_in(p0_writenum_out),

        .m1_write_in(p1_write_2out),
        .m2_write_in(p0_write_2out),
        .m3_write_in(p1_write_3out),
        .m4_write_in(p0_write_3out),
        .m5_write_in(p1_write_out),
        .m6_write_in(p0_write_out),

        .data_forwarded_out(p0_data_Rm_2in)
    );

    data_forward p0_data_Rn_forward(
        .data_reg_in(p0_data_Rn_regout),
        .num_reg_in(p0_num_Rn_1out),

        .data_m1_in(p1_result_2out_3in),
        .data_m2_in(p0_result_2out_3in),
        .data_m3_in(p1_result_3out_4in),
        .data_m4_in(p0_result_3out_4in),
        .data_m5_in(p1_writeback_data_out),
        .data_m6_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_2out),
        .num_m2_in(p0_writenum_2out),
        .num_m3_in(p1_writenum_3out),
        .num_m4_in(p0_writenum_3out),
        .num_m5_in(p1_writenum_out),
        .num_m6_in(p0_writenum_out),

        .m1_write_in(p1_write_2out),
        .m2_write_in(p0_write_2out),
        .m3_write_in(p1_write_3out),
        .m4_write_in(p0_write_3out),
        .m5_write_in(p1_write_out),
        .m6_write_in(p0_write_out),

        .data_forwarded_out(p0_data_Rn_2in)
    );

    data_forward p0_data_Rd_forward(
        .data_reg_in(p0_data_Rd_regout),
        .num_reg_in(p0_num_Rd_1out),

        .data_m1_in(p1_result_2out_3in),
        .data_m2_in(p0_result_2out_3in),
        .data_m3_in(p1_result_3out_4in),
        .data_m4_in(p0_result_3out_4in),
        .data_m5_in(p1_writeback_data_out),
        .data_m6_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_2out),
        .num_m2_in(p0_writenum_2out),
        .num_m3_in(p1_writenum_3out),
        .num_m4_in(p0_writenum_3out),
        .num_m5_in(p1_writenum_out),
        .num_m6_in(p0_writenum_out),

        .m1_write_in(p1_write_2out),
        .m2_write_in(p0_write_2out),
        .m3_write_in(p1_write_3out),
        .m4_write_in(p0_write_3out),
        .m5_write_in(p1_write_out),
        .m6_write_in(p0_write_out),

        .data_forwarded_out(p0_data_Rd_2in)
    );

    //pipeline 1 forward

    data_forward p1_data_Rm_forward(
        .data_reg_in(p1_data_Rm_regout),
        .num_reg_in(p1_num_Rm_1out),

        .data_m1_in(p1_result_2out_3in),
        .data_m2_in(p0_result_2out_3in),
        .data_m3_in(p1_result_3out_4in),
        .data_m4_in(p0_result_3out_4in),
        .data_m5_in(p1_writeback_data_out),
        .data_m6_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_2out),
        .num_m2_in(p0_writenum_2out),
        .num_m3_in(p1_writenum_3out),
        .num_m4_in(p0_writenum_3out),
        .num_m5_in(p1_writenum_out),
        .num_m6_in(p0_writenum_out),

        .m1_write_in(p1_write_2out),
        .m2_write_in(p0_write_2out),
        .m3_write_in(p1_write_3out),
        .m4_write_in(p0_write_3out),
        .m5_write_in(p1_write_out),
        .m6_write_in(p0_write_out),

        .data_forwarded_out(p1_data_Rm_2in)
    );

    data_forward p1_data_Rn_forward(
        .data_reg_in(p1_data_Rn_regout),
        .num_reg_in(p1_num_Rn_1out),

        .data_m1_in(p1_result_2out_3in),
        .data_m2_in(p0_result_2out_3in),
        .data_m3_in(p1_result_3out_4in),
        .data_m4_in(p0_result_3out_4in),
        .data_m5_in(p1_writeback_data_out),
        .data_m6_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_2out),
        .num_m2_in(p0_writenum_2out),
        .num_m3_in(p1_writenum_3out),
        .num_m4_in(p0_writenum_3out),
        .num_m5_in(p1_writenum_out),
        .num_m6_in(p0_writenum_out),

        .m1_write_in(p1_write_2out),
        .m2_write_in(p0_write_2out),
        .m3_write_in(p1_write_3out),
        .m4_write_in(p0_write_3out),
        .m5_write_in(p1_write_out),
        .m6_write_in(p0_write_out),

        .data_forwarded_out(p1_data_Rn_2in)
    );

    data_forward p1_data_Rd_forward(
        .data_reg_in(p1_data_Rd_regout),
        .num_reg_in(p1_num_Rd_1out),

        .data_m1_in(p1_result_2out_3in),
        .data_m2_in(p0_result_2out_3in),
        .data_m3_in(p1_result_3out_4in),
        .data_m4_in(p0_result_3out_4in),
        .data_m5_in(p1_writeback_data_out),
        .data_m6_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_2out),
        .num_m2_in(p0_writenum_2out),
        .num_m3_in(p1_writenum_3out),
        .num_m4_in(p0_writenum_3out),
        .num_m5_in(p1_writenum_out),
        .num_m6_in(p0_writenum_out),

        .m1_write_in(p1_write_2out),
        .m2_write_in(p0_write_2out),
        .m3_write_in(p1_write_3out),
        .m4_write_in(p0_write_3out),
        .m5_write_in(p1_write_out),
        .m6_write_in(p0_write_out),

        .data_forwarded_out(p1_data_Rd_2in)
    );


    //----------------pipeline0--------------------------
    pipeline_assembly p0(//Pipeline No.0
        .IR_in(p0_IR_in),
        .PC_in(p0_PC_in),

        .clk(clk),
        .rst(rst),

        .rst_p(p0_rst_HCU),//Not finished, waiting for BGU
        .update_1in(p0_update_1),

        .data_Rm_2in(p0_data_Rm_2in),
        .data_Rn_2in(p0_data_Rn_2in),
        .data_Rd_2in(p0_data_Rd_2in),

        .num_Rm_1out(p0_num_Rm_1out),
        .num_Rn_1out(p0_num_Rn_1out),
        .num_Rd_1out(p0_num_Rd_1out),
        
        .result_2out_3in(p0_result_2out_3in),
        .result_3out_4in(p0_result_3out_4in),
        .writenum_1out(p0_writenum_1out),
        .writenum_2out(p0_writenum_2out),
        .writenum_3out(p0_writenum_3out),
        .write_1out(p0_write_1out),
        .write_2out(p0_write_2out),
        .write_3out(p0_write_3out),

        .N_out(p0_N),
        .V_out(p0_V),
        .Z_out(p0_Z),

        .writeback_data_out(p0_writeback_data_out),
        .writenum_out(p0_writenum_out),
        .write_out(p0_write_out),
        
        .rdata_mem(p0_DM_rdata),
        .wdata_mem(p0_DM_wdata),
        .addr_mem(p0_DM_maddr),
        .write_mem(p0_DM_write_mem),

        .used_RmRnRd_1out(p0_used_RmRnRd_1out),   
        .inst_type_1out_2in(p0S1_inst_type),
        .inst_type_2out_3in(p0S2_inst_type),
        .inst_type_3out(p0S3_inst_type),
        //laods
        .loads_1out(p0_loads_1out),
        .loads_2out(p0_loads_2out)
    );

    regfile p0_REGFILE(
        .num_read0_in(p0_num_Rm_1out),//Rm
        .num_read1_in(p0_num_Rn_1out),//Rn
        .num_read2_in(p0_num_Rd_1out),//Rd

        .data_read0_out(p0_data_Rm_regout),
        .data_read1_out(p0_data_Rn_regout),
        .data_read2_out(p0_data_Rd_regout),

        //write1 has higher priority, implemented inside regfile
        .num_write0_in(p0_writenum_out),
        .num_write1_in(p1_writenum_out),

        .write0(p0_write_out),
        .write1(p1_write_out),  

        .data_write0_in(p0_writeback_data_out),
        .data_write1_in(p1_writeback_data_out),

        .clk(clk)
    );

    //----------------------pipeline1-------------------------
    pipeline_assembly p1(//Pipeline No.1
        .IR_in(p1_IR_in),
        .PC_in(p1_PC_in),

        .clk(clk),
        .rst(rst),

        .rst_p(p1_rst_HCU),//Not finished, waiting for BGU
        .update_1in(p1_update_1),

        .data_Rm_2in(p1_data_Rm_2in),
        .data_Rn_2in(p1_data_Rn_2in),
        .data_Rd_2in(p1_data_Rd_2in),

        .num_Rm_1out(p1_num_Rm_1out),
        .num_Rn_1out(p1_num_Rn_1out),
        .num_Rd_1out(p1_num_Rd_1out),
        
        .result_2out_3in(p1_result_2out_3in),
        .result_3out_4in(p1_result_3out_4in),
        .writenum_1out(p1_writenum_1out),
        .writenum_2out(p1_writenum_2out),
        .writenum_3out(p1_writenum_3out),
        .write_1out(p1_write_1out),
        .write_2out(p1_write_2out),
        .write_3out(p1_write_3out),

        .N_out(p1_N),
        .V_out(p1_V),
        .Z_out(p1_Z),

        .writeback_data_out(p1_writeback_data_out),
        .writenum_out(p1_writenum_out),
        .write_out(p1_write_out),
        
        .rdata_mem(p1_DM_rdata),
        .wdata_mem(p1_DM_wdata),
        .addr_mem(p1_DM_maddr),
        .write_mem(p1_DM_write_mem),
        
        .used_RmRnRd_1out(p1_used_RmRnRd_1out),
        .inst_type_1out_2in(p1S1_inst_type),
        .inst_type_2out_3in(p1S2_inst_type),
        .inst_type_3out(p1S3_inst_type),
        //laods
        .loads_1out(p1_loads_1out),
        .loads_2out(p1_loads_2out)
    );

    regfile p1_REGFILE(
        .num_read0_in(p1_num_Rm_1out),//Rm
        .num_read1_in(p1_num_Rn_1out),//Rn
        .num_read2_in(p1_num_Rd_1out),//Rd

        .data_read0_out(p1_data_Rm_regout),
        .data_read1_out(p1_data_Rn_regout),
        .data_read2_out(p1_data_Rd_regout),

        //write1 has higher priority, implemented inside regfile
        .num_write0_in(p0_writenum_out),
        .num_write1_in(p1_writenum_out),

        .write0(p0_write_out),
        .write1(p1_write_out),  

        .data_write0_in(p0_writeback_data_out),
        .data_write1_in(p1_writeback_data_out),

        .clk(clk)
    );

    HCU pHCU(
        .p0S1_inst_type(p0S1_inst_type),
        .p0S1_readnums({p0_num_Rm_1out,p0_num_Rn_1out,p0_num_Rd_1out}),
        .p0S1_writenum(p0_writenum_1out),
        .p0S1_write(p0_write_1out),
        .p0S1_used_RmRnRd(p0_used_RmRnRd_1out),

        .p1S1_readnums({p1_num_Rm_1out,p1_num_Rn_1out,p1_num_Rd_1out}),
        .p1S1_inst_type(p1S1_inst_type),
        .p1S1_used_RmRnRd(p1_used_RmRnRd_1out),

        .p0S2_inst_type(p0S2_inst_type),
        .p0S2_writenum(p0_writenum_2out),
        .p0S2_write(p0_write_2out),

        .p1S2_inst_type(p1S2_inst_type),
        .p1S2_writenum(p1_writenum_2out),
        .p1S2_write(p1_write_2out),

        .p0S3_inst_type(p0S3_inst_type),
        .p0S3_writenum(p0_writenum_3out),
        .p0S3_write(p0_write_3out),

        .p1S3_inst_type(p1S3_inst_type),
        .p1S3_writenum(p1_writenum_3out),
        .p1S3_write(p1_write_3out),

        .p0_update1_out(p0_update_1),
        .p1_update1_out(p1_update_1),
        .p0_rst_HCUout(p0_rst_HCU),
        .p1_rst_HCUout(p1_rst_HCU),
        .fetch_next(fetch_next)
    );


endmodule