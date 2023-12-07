module tb_top_HCU;
    reg [3:0] KEY;
    reg [9:0] SW;
    wire [9:0] LEDR; 
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg err;
    reg CLOCK_50;
    lab7bonus_top DUT (KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
    initial begin
        forever begin
            CLOCK_50=1'b0;
            #2;
            CLOCK_50=1'b1;
            #2;
        end
    end
    initial begin
        err=1'b0;
        KEY[1]=1'b0;
        @(posedge CLOCK_50);
        KEY[1]=1'b1;

        force DUT.CPU.p0_IR_in=16'b1101000100000010;
        force DUT.CPU.p1_IR_in=16'b1101001001000110;

        @(posedge CLOCK_50);
        force DUT.CPU.p0_IR_in=16'b1000001000100100;//STR R1
        force DUT.CPU.p1_IR_in=16'b0110001001100100;//LDR R3
        @(posedge CLOCK_50);
        force DUT.CPU.p0_IR_in=16'b1010000110000011;//ADD R4
        force DUT.CPU.p1_IR_in=16'b1000001010000000;//STR R4
        @(posedge CLOCK_50);
        force DUT.CPU.p0_IR_in=16'b0110001000000000;//LDR R0
        force DUT.CPU.p1_IR_in=16'b1000001000100000;//STR R1
        @(posedge DUT.CPU.fetch_next);
        @(posedge CLOCK_50);
        force DUT.CPU.p0_IR_in=16'b0;
        force DUT.CPU.p1_IR_in=16'b0;
        @(posedge CLOCK_50);
        force DUT.CPU.p0_IR_in=16'b0;
        force DUT.CPU.p1_IR_in=16'b0;
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);

        #10;
        $stop;
    end
endmodule

module tb_top_wPC;
    reg [3:0] KEY;
    reg [9:0] SW;
    wire [9:0] LEDR; 
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg CLOCK_50;
    integer counter;
    lab7bonus_top DUT (KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
    initial begin
        counter=0;
        forever begin
            CLOCK_50=1'b0;
            #2;
            CLOCK_50=1'b1;
            #2;
            counter+=1;
        end
    end
    always @(posedge LEDR[8]) begin
        $display("Halted. PC at %h.",DUT.CPU.PC);
        $display("Total runtime %d periods.",counter);
        #20;
        $stop;
    end
    initial begin
        KEY[1]=1'b0;
        @(posedge CLOCK_50);
        #1;
        KEY[1]=1'b1;
        #100000;
        $stop;
    end
endmodule