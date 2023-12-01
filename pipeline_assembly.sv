module pipeline_assembly (
    input clk
);

    pipeline_0_decode S0_DECODE(
        .IR_in(),
        .PC(),

        .control_out(),
        .num_Rm(),
        .num_Rn(),
        .num_Rd(),
        .sximm()
    );

    pipeline_1_readreg S1_READREG(
        .control_in(),
        .num_Rm_in(),
        .num_Rn_in(),
        .num_Rd_in(),
        .imm_in(),

        .rst(),
        .clk(clk),
        .update(),

        .control_out(),
        .num_Rm_out(),
        .num_Rn_out(),
        .num_Rd_out(),
        .imm_out(),

        .loads()
    );

    pipeline_2_execute S2_EXECUTE(
        .control_in(),
        /*
        Do we really need regnums here...?
        */
        .data_Rm_in(),
        .data_Rn_in(),
        .data_Rd_in(),
        .imm_in(),

        .rst(),
        .clk(clk),

        .control_out(),
        /*
        Do we really need regnums here...?
        */
        .data_Rd_out(),
        .result_out(),
        .highbit_shifted_Rm_out(),
        .highbit_data_Rn_out(),

        .loads()
    );

    pipeline_3_memwrt S3_MEMWRT(
        .control_in(),
        .data_Rd_in(),
        .highbit_shifted_Rm_in(),
        .highbit_data_Rn_in(),
        .result_in(),

        .rst(),
        .clk(clk),

        .result_out(),
        .N_out(),
        .V_out(),
        .Z_out(),
        .control_out(),

        .wdata_mem(),
        .addr_mem(),
        .write_mem()
    );

    pipeline_4_regwrt S4_REGWRT(
        .control_in(),
        .rdata_in(),
        .result_in(),

        .rst(),
        .clk(clk),

        .writeback_data_out(),
        .writenum_out(),
        .write_out()
    );

    
endmodule