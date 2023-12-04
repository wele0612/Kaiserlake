module lab7bonus_check_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;
  reg CLOCK_50;

  lab7bonus_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

  initial forever begin
    CLOCK_50 = 0; #5;
    CLOCK_50 = 1; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    // check if program from Figure 2 in Lab 8 handout can be found loaded in memory
    if (DUT.MEM.mem[0] !== 16'b1101000000001111) begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b0110000000000000) begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[2] !== 16'b1101000100000000) begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[3] !== 16'b1101001000000000) begin err = 1; $display("FAILED: mem[3] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[4] !== 16'b1101001100010000) begin err = 1; $display("FAILED: mem[4] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[5] !== 16'b1101010000000001) begin err = 1; $display("FAILED: mem[5] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[6] !== 16'b1010001110100001) begin err = 1; $display("FAILED: mem[6] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[7] !== 16'b0110010110100000) begin err = 1; $display("FAILED: mem[7] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[8] !== 16'b1010001001000101) begin err = 1; $display("FAILED: mem[8] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[9] !== 16'b1010000100100100) begin err = 1; $display("FAILED: mem[9] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[10] !== 16'b1010100100000000) begin err = 1; $display("FAILED: mem[10] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[11] !== 16'b0010001111111010) begin err = 1; $display("FAILED: mem[11] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[12] !== 16'b1101001100010100) begin err = 1; $display("FAILED: mem[12] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[13] !== 16'b1000001101000000) begin err = 1; $display("FAILED: mem[13] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[14] !== 16'b1110000000000000) begin err = 1; $display("FAILED: mem[14] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[15] !== 16'b0000000000000100) begin err = 1; $display("FAILED: mem[15] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[16] !== 16'b0000000000110010) begin err = 1; $display("FAILED: mem[16] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[17] !== 16'b0000000011001000) begin err = 1; $display("FAILED: mem[17] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[18] !== 16'b0000000001100100) begin err = 1; $display("FAILED: mem[18] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[19] !== 16'b0000000111110100) begin err = 1; $display("FAILED: mem[19] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[20] !== 16'b1011101011011101) begin err = 1; $display("FAILED: mem[20] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end
    if (DUT.MEM.mem[21] !== 16'b0000000000000000) begin err = 1; $display("FAILED: mem[21] wrong; please set data.txt using lab7bonusfig2.s"); $stop; end

    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

    #10; // waiting for RST state to cause reset of PC
    if (DUT.CPU.PC !== 9'h0) begin err = 1; $display("FAILED: PC did not reset to 0."); $stop; end

    // If your simlation never gets past the the line below, check if your CMP instruction is working
    @(posedge LEDR[8]); // set LEDR[8] to one when executing HALT

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    // NOTE: if HALT is working, PC won't change after reaching 0xE
    if (DUT.CPU.PC !== 9'hF) begin err = 1; $display("FAILED: PC at HALT is incorrect."); $stop; end
    if (DUT.CPU.DP.REGFILE.R4 !== 16'h1) begin err = 1; $display("FAILED: R4 incorrect at exit; did MOV R4,#1 not work?"); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h4) begin err = 1; $display("FAILED: R0 incorrect at exit; did LDR R0,[R0] not work?"); $stop; end

    // check memory contents for result
    if (DUT.MEM.mem[8'h14] === 16'h0) begin 
      err = 1; 
      $display("FAILED: mem[0x14] (result) is wrong;");
      if (DUT.CPU.DP.REGFILE.R3 === 16'h10)
        $display("        hint: check if your BLT instruction skipped MOV R3, result"); 
      $stop; 
    end
    if (DUT.MEM.mem[8'h14] !== 16'd850)  begin err = 1; $display("FAILED: mem[0x14] (result) is wrong;"); $stop; end

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
