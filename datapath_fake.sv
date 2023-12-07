module datapath_fake (
    input [2:0] num_write0_in,
    input [2:0] num_write1_in,

    input write0,
    input write1,

    input [15:0] data_write0_in,
    input [15:0] data_write1_in,

    //input rst, //Consider this later
    input clk
);
    regfile_fake REGFILE(
        .num_write0_in(num_write0_in),
        .num_write1_in(num_write1_in),

        .write0(write0),
        .write1(write1),

        .data_write0_in(data_write0_in),
        .data_write1_in(data_write1_in),

        .clk(clk)
    );
    
endmodule

module regfile_fake (

    input [2:0] num_write0_in,
    input [2:0] num_write1_in,

    input write0,
    input write1,

    input [15:0] data_write0_in,
    input [15:0] data_write1_in,

    //input rst, //Consider this later
    input clk

);

    reg [15:0] regs [7:0]; 

    wire [15:0] R0,R1,R2,R3,R4,R5,R6,R7;//to be recognized by the autograder
    assign R0=regs[0];
    assign R1=regs[1];
    assign R2=regs[2];
    assign R3=regs[3];
    assign R4=regs[4];
    assign R5=regs[5];
    assign R6=regs[6];
    assign R7=regs[7];

    always @(posedge clk) begin
        if (write0) begin
            regs[num_write0_in]=data_write0_in;
        end
        if (write1) begin
            regs[num_write1_in]=data_write1_in;
        end
    end
endmodule