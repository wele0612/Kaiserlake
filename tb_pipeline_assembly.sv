module tb_pipeline_noforward ();
    reg [15:0] p0_IR_in,p1_IR_in;
    reg [7:0] p0_PC_in,p1_PC_in;
    reg clk, rst;

    wire [8:0] p0_DM_maddr;
    wire [15:0] p0_DM_wdata;
    wire p0_DM_write_mem;
    wire [8:0] p1_DM_maddr;
    wire [15:0] p1_DM_wdata;
    wire p1_DM_write_mem;
    wire [15:0] p0_DM_rdata;
    wire [15:0] p1_DM_rdata;

    cpu CPU(
    clk,
    rst,
    //For test only ----
    p0_IR_in,
    p1_IR_in,
    p0_PC_in,
    p1_PC_in,
    //------------------
    p0_DM_rdata,
    p0_DM_maddr,
    p0_DM_wdata,
    p0_DM_write_mem,

    p1_DM_rdata,
    p1_DM_maddr,
    p1_DM_wdata,
    p1_DM_write_mem);

    initial begin
        repeat(200) begin
            clk=1'b0;
            #5;
            clk=1'b1;
            #5;
        end 
    end

    initial begin
        rst=1'b1;
        @(posedge clk);
        rst=1'b0;

        //MOV R0,#2;
        p0_IR_in=16'b110_10_000_00000010;
        //MOV R1,#2;
        p1_IR_in=16'b110_10_001_00000010;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        //ADD R3,R1,R0,LSL#1
        //ADD R4,R1,R0,LSL#1
        p0_IR_in=16'b101_00_001_011_01_000;
        p1_IR_in=16'b101_00_001_100_01_000;


    end
endmodule

module tb_pipeline_forward ();
    reg [15:0] p0_IR_in,p1_IR_in;
    reg [7:0] p0_PC_in,p1_PC_in;
    reg clk, rst;

    wire [8:0] p0_DM_maddr;
    wire [15:0] p0_DM_wdata;
    wire p0_DM_write_mem;
    wire [8:0] p1_DM_maddr;
    wire [15:0] p1_DM_wdata;
    wire p1_DM_write_mem;
    wire [15:0] p0_DM_rdata;
    wire [15:0] p1_DM_rdata;

    cpu CPU(
    clk,
    rst,
    //For test only ----
    p0_IR_in,
    p1_IR_in,
    p0_PC_in,
    p1_PC_in,
    //------------------
    p0_DM_rdata,
    p0_DM_maddr,
    p0_DM_wdata,
    p0_DM_write_mem,

    p1_DM_rdata,
    p1_DM_maddr,
    p1_DM_wdata,
    p1_DM_write_mem);

    initial begin
        repeat(200) begin
            clk=1'b0;
            #5;
            clk=1'b1;
            #5;
        end 
    end

    initial begin
        rst=1'b1;
        @(posedge clk);
        rst=1'b0;

        //MOV R0,#2;
        p0_IR_in=16'b110_10_000_00000010;
        //MOV R1,#2;
        p1_IR_in=16'b110_10_001_00000010;
        @(posedge clk);
        //ADD R3,R1,R0,LSL#1
        //ADD R4,R1,R0,LSL#1
        p0_IR_in=16'b101_00_001_011_01_000;
        p1_IR_in=16'b101_00_001_100_01_000;
        @(posedge clk);
        //ADD R2,R1,R3
        //AND R5,R2,R4,LSL#1
        p0_IR_in=16'b101_00_001_010_00_011;
        p1_IR_in=16'b110_10_010_101_01_100;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

    end
endmodule