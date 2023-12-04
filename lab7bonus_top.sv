module lab7bonus_top (
    KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50
);
  input [3:0] KEY;
  input [9:0] SW;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;

  wire clk;
  assign clk=CLOCK_50;

  wire [15:0] p0_DM_rdata,p1_DM_rdata;
  wire [15:0] p0_DM_wdata,p1_DM_wdata;
  wire [8:0] p0_DM_maddr,p1_DM_maddr;
  wire p0_DM_write_mem,p1_DM_write_mem;
  wire mem_we_a,mem_we_b;
  assign mem_we_b=p1_DM_write_mem;
  //To resolve possible write conflict
  assign mem_we_a=
    (p0_DM_maddr==p1_DM_maddr&&p1_DM_write_mem)?1'b0:p0_DM_write_mem;

  cpu CPU(
    .clk(clk),
    .rst(~KEY[1]),

    .p0_DM_rdata(p0_DM_rdata),
    .p0_DM_maddr(p0_DM_maddr),
    .p0_DM_wdata(p0_DM_wdata),
    .p0_DM_write_mem(p0_DM_write_mem),

    .p1_DM_rdata(p1_DM_rdata),
    .p1_DM_maddr(p1_DM_maddr),
    .p1_DM_wdata(p1_DM_wdata),
    .p1_DM_write_mem(p1_DM_write_mem)

  );

  true_dpram_sclk MEM(
    .clk(clk),

    .data_a(p0_DM_wdata),
    .addr_a(p0_DM_maddr[7:0]),
    .we_a(mem_we_a),
    .q_a(p0_DM_rdata),

    .data_b(p1_DM_wdata),
    .addr_b(p1_DM_maddr[7:0]),
    .we_b(mem_we_b),
    .q_b(p1_DM_rdata)
  );
    
endmodule