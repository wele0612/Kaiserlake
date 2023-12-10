module pipeline_4_regwrt (
    input [21:0] control_in,
    input [15:0] rdata_in, //this one need no pipeline reg! reg included in the sync-ram output
    input [15:0] result_in,
    input [15:0] delayed_B_in,
    input do_delayed_B_in,
    input fetch_next_in,

    input clk,rst,
    input power_rst,

    output [15:0] delayed_B_out,
    output do_delayed_B_out,
    output [15:0] writeback_data_out,
    output [2:0] writenum_out,
    output write_out
); 

    wire [15:0] result;
    wire [21:0] control;
    wire do_delayed_B;
    vDFF_nr #16 pREG_result (clk,result_in,result);
    vDFF #22 pREG_control (clk,rst,control_in,control);

    vDFF_ennr #16 pREG_delayed_B (clk,fetch_next_in||(~do_delayed_B),delayed_B_in,delayed_B_out);
    vDFF_en pREG_do_delayed_B (clk,power_rst||(rst&&(~do_delayed_B))||(rst&&fetch_next_in),fetch_next_in||(~do_delayed_B),do_delayed_B_in,do_delayed_B);
    //do_delayed_B_out high will cause reset to entire pipeline, including here.
    //delayed branch instruction should wait here when fetch_next is low
    //And it can be mistakenly reset by itself while waiting... so we neet to fix rst. See cpu.sv
    assign do_delayed_B_out=do_delayed_B;

    wire [2:0] opcode;
    assign opcode=control[21:19];

    wire is_ldr;
    assign is_ldr=(opcode==3'b011);

    assign writeback_data_out=is_ldr?rdata_in:result;//for LDR, we are writting back memory data
    assign write_out=control[3];
    assign writenum_out=control[2:0];

endmodule
