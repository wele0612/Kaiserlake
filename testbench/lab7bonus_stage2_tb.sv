module lab7bonus_stage2_tb;
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
  wire break = (LEDR[8] == 1'b1);
  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4
    while (~break) begin
      // Change the following line to wait until your CPU starts to you fetch
      // the next instruction (e.g., IF1 state from Lab 7 or equivalent in
      // your design).  DUT.CPU.FSM is not required for by the autograder
      // for Lab 8. 
      @(posedge (DUT.CPU.FSM.present_state == `YOUR_IF1_STATE) or posedge break);  

      @(negedge CLOCK_50); // show advance to negative edge of clock
      $display("PC = %h", DUT.CPU.PC); 
    end
    if (DUT.MEM.mem[25] !== -16'd23) begin err = 1; $display("FAILED: mem[25] wrong"); $stop; end
    if (~err) $display("PASSED");
    $stop;
  end
endmodule
