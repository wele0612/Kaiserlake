module KaiserLake_top (
    KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50
);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;

  wire clk,rst;
  assign clk=CLOCK_50;
  assign rst=~KEY[1];

  wire [15:0] p0_DM_rdata,p1_DM_rdata;
  wire [15:0] p0_DM_wdata,p1_DM_wdata;
  wire [8:0] p0_DM_maddr,p1_DM_maddr;

  wire [8:0] p0_IM_maddr,p1_IM_maddr;
  wire [15:0] p0_IM_rdata,p1_IM_rdata;

  wire p0_DM_write_mem,p1_DM_write_mem;
  wire mem_we_a,mem_we_b;
  wire IM_ena;
  wire [7:0] halt_addr;

  //for timing anlysis
  assign LEDR[5]=p0_DM_rdata[0];

  assign mem_we_b=p1_DM_write_mem;
  //To resolve possible write conflict
  assign mem_we_a=
    (p0_DM_maddr==p1_DM_maddr&&p1_DM_write_mem)?1'b0:p0_DM_write_mem;
  
  sseg SSEG0(halt_addr[3:0],HEX0);
  sseg SSEG1(halt_addr[7:4],HEX1);

  cpu CPU(
    .clk(clk),
    .rst(rst),
    .power_rst(rst),

    .p0_DM_rdata(p0_DM_rdata),
    .p0_DM_maddr(p0_DM_maddr),
    .p0_DM_wdata(p0_DM_wdata),
    .p0_DM_write_mem(p0_DM_write_mem),

    .p1_DM_rdata(p1_DM_rdata),
    .p1_DM_maddr(p1_DM_maddr),
    .p1_DM_wdata(p1_DM_wdata),
    .p1_DM_write_mem(p1_DM_write_mem),

    .p0_IM_rdata(p0_IM_rdata),
    .p0_IM_maddr(p0_IM_maddr),
    .p1_IM_rdata(p1_IM_rdata),
    .p1_IM_maddr(p1_IM_maddr),

    .IM_ena(IM_ena),
    .halted(LEDR[8]),
    .halt_addr(halt_addr)
  );

  true_dpram_sclk MEM(
    .clk(clk),
    .ena(1'b1),

    .data_a(p0_DM_wdata),
    .addr_a(p0_DM_maddr[7:0]),
    .we_a(mem_we_a),
    .q_a(p0_DM_rdata),

    .data_b(p1_DM_wdata),
    .addr_b(p1_DM_maddr[7:0]),
    .we_b(mem_we_b),
    .q_b(p1_DM_rdata)
  );

  true_dpram_sclk IMEM(
    .clk(clk),
    .ena(IM_ena),

    .data_a(16'b0),
    .addr_a(rst?8'b0:p0_IM_maddr[7:0]),
    .we_a(1'b0),
    .q_a(p0_IM_rdata),

    .data_b(16'b0),
    .addr_b(rst?8'b0:p1_IM_maddr[7:0]),
    .we_b(1'b0),
    .q_b(p1_IM_rdata)
  );


/*
  dprom_sclk IMEM(
    .clk(clk),
    
    .addr_a(p0_IM_maddr[7:0]),
    .q_a(p0_IM_rdata[7:0]),
    
    .addr_b(p1_IM_maddr[7:0]),
    .q_b(p1_IM_rdata)
  );
  */
    
endmodule

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;
  // One bit per segment. On the DE1-SoC a HEX segment is illuminated when
  // the input bit is 0. Bits 6543210 correspond to:
  //
  //    0000
  //   5    1
  //   5    1
  //    6666
  //   4    2
  //   4    2
  //    3333
  //
  // Decimal value | Hexadecimal symbol to render on (one) HEX display
  //             0 | 0
  //             1 | 1
  //             2 | 2
  //             3 | 3
  //             4 | 4
  //             5 | 5
  //             6 | 6
  //             7 | 7
  //             8 | 8
  //             9 | 9
  //            10 | A
  //            11 | b
  //            12 | C
  //            13 | d
  //            14 | E
  //            15 | F

  always@(*) begin
  case (in)
    4'b0000: segs=7'b1000000;//0
    4'b0001: segs=7'b1111001;//1
    4'b0010: segs=7'b0100100;//2
    4'b0011: segs=7'b0110000;//3
    4'b0100: segs=7'b0011001;//4
    4'b0101: segs=7'b0010010;//5
    4'b0110: segs=7'b0000010;//6
    4'b0111: segs=7'b1111000;//7
    4'b1000: segs=7'b0000000;//8
    4'b1001: segs=7'b0010000;//9
    4'b1010: segs=7'b0001000;//A
    4'b1011: segs=7'b1100000;//b
    4'b1100: segs=7'b1000110;//C
    4'b1101: segs=7'b0100001;//D
    4'b1110: segs=7'b0000110;//E
    4'b1111: segs=7'b0001110;//F
    default: segs=7'b0;
endcase
end

endmodule