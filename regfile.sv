/*
Currently 2-write 3-read mode
*/
module regfile (
    input [2:0] num_read0_in,
    input [2:0] num_read1_in,
    input [2:0] num_read2_in,
    /*input [2:0] num_read3_in,
    input [2:0] num_read4_in,
    input [2:0] num_read5_in,
    */

    input [2:0] num_write0_in,
    input [2:0] num_write1_in,

    input write0,
    input write1,

    input [15:0] data_write0_in,
    input [15:0] data_write1_in,

    //input rst, //Consider this later
    input clk,
    
    output [15:0] data_read0_out,
    output [15:0] data_read1_out,
    
    output [15:0] data_read2_out
    /*output [15:0] data_read3_out,
    output [15:0] data_read4_out,
    output [15:0] data_read5_out
    */
);

    reg [15:0] regs [7:0]; 

    always @(*) begin
        data_read0_out=regs[num_read0_in];
        data_read1_out=regs[num_read1_in];
        data_read2_out=regs[num_read2_in];
        /*
        data_read3_out=regs[num_read3_in];
        data_read4_out=regs[num_read4_in];
        data_read5_out=regs[num_read5_in];
        */
    end

    always @(posedge clk) begin
        if (write0) begin
            regs[num_write0_in]<=data_write0_in;
        end
        if (write1) begin
            regs[num_write1_in]<=data_write1_in;
        end
    end
    
endmodule