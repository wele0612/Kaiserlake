module pipeline_4_regwrt (
    input [21:0] control_in,
    input [15:0] rdata_in, //this one need no pipeline reg! reg included in the sync-ram output
    input [15:0] result_in,
    input [15:0] delayed_B_in,
    input do_delayed_B_in,

    input clk,rst,

    output [15:0] delayed_B_out,
    output do_delayed_B_out,
    output [15:0] writeback_data_out,
    output [2:0] writenum_out,
    output write_out
); 

    wire [15:0] result;
    wire [21:0] control;
    vDFF_nr #16 pREG_result (clk,result_in,result);
    vDFF #22 pREG_control (clk,rst,control_in,control);

    vDFF_nr #16 pREG_delayed_B (clk,delayed_B_in,delayed_B_out);
    vDFF pREG_do_delayed_B (clk,rst,do_delayed_B_in,do_delayed_B_out);

    wire [2:0] opcode;
    assign opcode=control[21:19];

    wire is_ldr;
    assign is_ldr=(opcode==3'b011);

    assign writeback_data_out=is_ldr?rdata_in:result;//for LDR, we are writting back memory data
    assign write_out=control[3];
    assign writenum_out=control[2:0];

endmodule
