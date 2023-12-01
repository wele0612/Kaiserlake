module cpu (

    input clk,
    input rst,

    //For test only ----
    input [15:0] p0_IR_in,
    input [15:0] p1_IR_in,
    input [7:0] p0_PC_in,
    input [7:0] p1_PC_in,
    //------------------
    
    input [15:0] p0_DM_rdata,
    output [8:0] p0_DM_maddr,
    output [15:0] p0_DM_wdata,
    output p0_DM_write_mem,

    input [15:0] p1_DM_rdata,
    output [8:0] p1_DM_maddr,
    output [15:0] p1_DM_wdata,
    output p1_DM_write_mem

);
    //-------Pipline 0 signal declare---------------
    wire [2:0] p0_num_Rm_2out,p0_num_Rn_2out,p0_num_Rd_2out;
    wire [15:0] p0_data_Rm_2out,p0_data_Rn_2out,p0_data_Rd_2out;
    wire [15:0] p0_data_fRm_2in,p0_data_fRn_2in,p0_data_fRd_3in;

    wire [15:0] p0_result_3out_4in;

    wire [15:0] p0_writeback_data_out;
    wire [2:0] p0_writenum_4out;
    wire p0_write_4out;

    wire [2:0] p0_writenum_3out;
    wire p0_write_3out;

    //To BGU
    wire p0_N,p0_V,p0_Z;
    wire p0_loads_1out,p0_loads_2out;

    //-------Pipline 1 signal declare---------------
    wire [2:0] p1_num_Rm_2out,p1_num_Rn_2out,p1_num_Rd_2out;
    wire [15:0] p1_data_Rm_2out,p1_data_Rn_2out,p1_data_Rd_2out;
    wire [15:0] p1_data_fRm_2in,p1_data_fRn_2in,p1_data_fRd_3in;

    wire [15:0] p1_result_3out_4in;

    wire [15:0] p1_writeback_data_out;
    wire [2:0] p1_writenum_4out;
    wire p1_write_4out;

    wire [2:0] p1_writenum_3out;
    wire p1_write_3out;

    //To BGU
    wire p1_N,p1_V,p1_Z;
    wire p1_loads_1out,p1_loads_2out;
 
    //----------------pipeline0--------------------------
    pipeline_assembly p0(//Pipeline No.0
        .IR_in(p0_IR_in),
        .PC_in(p0_PC_in),

        .clk(clk),
        .rst(rst),
        .rst_p(4'b0),//not used yet
        .update_1in(1'b1),//not used yet

        .num_Rm_2out(p0_num_Rm_2out),
        .num_Rn_2out(p0_num_Rn_2out),
        .num_Rd_2out(p0_num_Rd_2out),
        
        .result_3out_4in(p0_result_3out_4in),
        .writenum_3out(p0_writenum_3out),
        .write_3out(p0_write_3out),

        .N_out(p0_N),
        .V_out(p0_V),
        .Z_out(p0_Z),

        .writeback_data_out(p0_writeback_data_out),
        .writenum_out(p0_writenum_4out),
        .write_out(p0_write_4out),
        
        .rdata_mem(p0_DM_rdata),
        .wdata_mem(p0_DM_wdata),
        .addr_mem(p0_DM_maddr),
        .write_mem(p0_DM_write_mem),
        
        //laods
        .loads_1out(p0_loads_1out),
        .loads_2out(p0_loads_2out),

        .data_fRm_2in(p0_data_fRm_2in),
        .data_fRn_2in(p0_data_fRn_2in),
        .data_fRd_3in(p0_data_fRd_3in),

        .data_Rm_2out(p0_data_Rm_2out),
        .data_Rn_2out(p0_data_Rn_2out),
        .data_Rd_2out(p0_data_Rd_2out),

        .num_write0_in(p0_writenum_4out),
        .num_write1_in(p1_writenum_4out),
        .write0_in(p0_write_4out),
        .write1_in(p1_write_4out),
        .data_write0_in(p0_writeback_data_out),
        .data_write1_in(p1_writeback_data_out)
    );

    //----------------pipeline1--------------------------
    pipeline_assembly p1(//Pipeline No.0
        .IR_in(p1_IR_in),
        .PC_in(p1_PC_in),

        .clk(clk),
        .rst(rst),
        .rst_p(4'b0),//not used yet
        .update_1in(1'b1),//not used yet

        .num_Rm_2out(p1_num_Rm_2out),
        .num_Rn_2out(p1_num_Rn_2out),
        .num_Rd_2out(p1_num_Rd_2out),
        
        .result_3out_4in(p1_result_3out_4in),
        .writenum_3out(p1_writenum_3out),
        .write_3out(p1_write_3out),

        .N_out(p1_N),
        .V_out(p1_V),
        .Z_out(p1_Z),

        .writeback_data_out(p1_writeback_data_out),
        .writenum_out(p1_writenum_4out),
        .write_out(p1_write_4out),
        
        .rdata_mem(p1_DM_rdata),
        .wdata_mem(p1_DM_wdata),
        .addr_mem(p1_DM_maddr),
        .write_mem(p1_DM_write_mem),
        
        //laods
        .loads_1out(p1_loads_1out),
        .loads_2out(p1_loads_2out),

        .data_fRm_2in(p1_data_fRm_2in),
        .data_fRn_2in(p1_data_fRn_2in),
        .data_fRd_3in(p1_data_fRd_3in),

        .data_Rm_2out(p1_data_Rm_2out),
        .data_Rn_2out(p1_data_Rn_2out),
        .data_Rd_2out(p1_data_Rd_2out),

        .num_write0_in(p0_writenum_4out),
        .num_write1_in(p1_writenum_4out),
        .write0_in(p0_write_4out),
        .write1_in(p1_write_4out),
        .data_write0_in(p0_writeback_data_out),
        .data_write1_in(p1_writeback_data_out)
    );


    //-----pipeline 0 forwarding------
    data_forward p0_Rm_forward(
        .data_reg_in(p0_data_Rm_2out),
        .num_reg_in(p0_num_Rm_2out),

        .data_m1_in(p1_result_3out_4in),
        .data_m2_in(p0_result_3out_4in),
        .data_m3_in(p1_writeback_data_out),
        .data_m4_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_3out),
        .num_m2_in(p0_writenum_3out),
        .num_m3_in(p1_writenum_4out),
        .num_m4_in(p0_writenum_4out),

        .m1_write_in(p1_write_3out),
        .m2_write_in(p0_write_3out),
        .m3_write_in(p1_write_4out),
        .m4_write_in(p0_write_4out),

        .data_forwarded_out(p0_data_fRm_2in)
    );

    data_forward p0_Rn_forward(
        .data_reg_in(p0_data_Rn_2out),
        .num_reg_in(p0_num_Rn_2out),

        .data_m1_in(p1_result_3out_4in),
        .data_m2_in(p0_result_3out_4in),
        .data_m3_in(p1_writeback_data_out),
        .data_m4_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_3out),
        .num_m2_in(p0_writenum_3out),
        .num_m3_in(p1_writenum_4out),
        .num_m4_in(p0_writenum_4out),

        .m1_write_in(p1_write_3out),
        .m2_write_in(p0_write_3out),
        .m3_write_in(p1_write_4out),
        .m4_write_in(p0_write_4out),

        .data_forwarded_out(p0_data_fRn_2in)
    );

    data_forward p0_Rd_forward(
        .data_reg_in(p0_data_Rd_2out),
        .num_reg_in(p0_num_Rd_2out),

        .data_m1_in(p1_result_3out_4in),
        .data_m2_in(p0_result_3out_4in),
        .data_m3_in(p1_writeback_data_out),
        .data_m4_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_3out),
        .num_m2_in(p0_writenum_3out),
        .num_m3_in(p1_writenum_4out),
        .num_m4_in(p0_writenum_4out),

        .m1_write_in(p1_write_3out),
        .m2_write_in(p0_write_3out),
        .m3_write_in(p1_write_4out),
        .m4_write_in(p0_write_4out),

        .data_forwarded_out(p0_data_fRd_3in)
    );
    
    //-----pipeline 1 forwarding------
    data_forward p1_Rm_forward(
        .data_reg_in(p1_data_Rm_2out),
        .num_reg_in(p1_num_Rm_2out),

        .data_m1_in(p1_result_3out_4in),
        .data_m2_in(p0_result_3out_4in),
        .data_m3_in(p1_writeback_data_out),
        .data_m4_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_3out),
        .num_m2_in(p0_writenum_3out),
        .num_m3_in(p1_writenum_4out),
        .num_m4_in(p0_writenum_4out),

        .m1_write_in(p1_write_3out),
        .m2_write_in(p0_write_3out),
        .m3_write_in(p1_write_4out),
        .m4_write_in(p0_write_4out),

        .data_forwarded_out(p1_data_fRm_2in)
    );

    data_forward p1_Rn_forward(
        .data_reg_in(p1_data_Rn_2out),
        .num_reg_in(p1_num_Rn_2out),

        .data_m1_in(p1_result_3out_4in),
        .data_m2_in(p0_result_3out_4in),
        .data_m3_in(p1_writeback_data_out),
        .data_m4_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_3out),
        .num_m2_in(p0_writenum_3out),
        .num_m3_in(p1_writenum_4out),
        .num_m4_in(p0_writenum_4out),

        .m1_write_in(p1_write_3out),
        .m2_write_in(p0_write_3out),
        .m3_write_in(p1_write_4out),
        .m4_write_in(p0_write_4out),

        .data_forwarded_out(p1_data_fRn_2in)
    );

    data_forward p1_Rd_forward(
        .data_reg_in(p1_data_Rd_2out),
        .num_reg_in(p1_num_Rd_2out),

        .data_m1_in(p1_result_3out_4in),
        .data_m2_in(p0_result_3out_4in),
        .data_m3_in(p1_writeback_data_out),
        .data_m4_in(p0_writeback_data_out),

        .num_m1_in(p1_writenum_3out),
        .num_m2_in(p0_writenum_3out),
        .num_m3_in(p1_writenum_4out),
        .num_m4_in(p0_writenum_4out),

        .m1_write_in(p1_write_3out),
        .m2_write_in(p0_write_3out),
        .m3_write_in(p1_write_4out),
        .m4_write_in(p0_write_4out),

        .data_forwarded_out(p1_data_fRd_3in)
    );


endmodule