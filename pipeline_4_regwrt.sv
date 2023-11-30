module pipeline_4_regwrt (
    control_in,memvalue_in,result_in,clk,rst,
    writeback_data,writenum,write
);
    parameter control_width=22;  
    input [control_width-1:0] control_in;
    input [15:0] memvalue_in; //this one need no pipeline reg! reg included in the sync-ram output
    input [15:0] result_in;
    input clk,rst;

    output [15:0] writeback_data;
    output [2:0] writenum;
    output write;

    wire [15:0] result;
    wire [control_width-1:0] control_out;
    vDFF #16 result_reg (clk,rst,result_in,result);
    vDFF #22 control (clk,rst,control_in,control_out); // USE OF PARAMETER WILL CAUSE ERRORS!!!


    wire [2:0] opcode;
    assign opcode=control_out[21:19];
    wire is_ldr;
    assign is_ldr=(opcode==3'b011);
    assign writeback_data=is_ldr?memvalue_in:result;//for LDR, we are writting back memory data
    assign write=control_out[3];
    assign writenum=control_out[2:0];

    
endmodule
