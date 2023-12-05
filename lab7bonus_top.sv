module lab7bonus_top (
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

  //for timing anlysis
  assign LEDR[5]=p0_DM_rdata[0];

  assign mem_we_b=p1_DM_write_mem;
  //To resolve possible write conflict
  assign mem_we_a=
    (p0_DM_maddr==p1_DM_maddr&&p1_DM_write_mem)?1'b0:p0_DM_write_mem;

  cpu CPU(
    .clk(clk),
    .rst(rst),

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
    .p1_IM_maddr(p1_IM_maddr)

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

  true_dpram_sclk IMEM(
    .clk(clk),

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