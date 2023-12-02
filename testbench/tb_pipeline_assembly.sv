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
        p0_IR_in=16'B1010000101101000;
        p1_IR_in=16'B1010000110010000;
        @(posedge clk);
        //ADD R2,R1,R3
        //AND R5,R2,R4
        p0_IR_in=16'b101_00_001_010_00_011;
        p1_IR_in=16'b1011001110100100;
        @(posedge clk);
        p0_IR_in=16'b1100000010001001;  //MOV R4,R1,LSL#1 
        p1_IR_in=16'b1100000010010001;  //MOV R4,R1,LSR#1 
        @(posedge clk);
        p0_IR_in=16'b1010110000000000;  //CMP R4,R0 
        p1_IR_in=16'b1011100010100100;  //MVN R5,R4
        @(posedge clk);
        p0_IR_in=16'b1010110100000000;  //CMP R5,R0 
        //p0_IR_in=16'd0;
        p1_IR_in=16'b1010100100000100;  //CMP R1,R4
        @(posedge clk);
        p0_IR_in=16'b0110000110100000;  //LDR R5,[R1]
        p1_IR_in=16'b1000000101000000;  //STR R1,[R1]
        force CPU.p0_DM_rdata=16'd100;
        @(posedge clk);
        p0_IR_in=16'b0;
        p1_IR_in=16'b0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        #10;
        $stop;

    end
endmodule