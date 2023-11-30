module pieline_1_readreg (
    control_in,
    readnum_a_in,
    readnum_b_in,
    readnum_ram_in,
    imm_in,
    write,
    writenum,
    writedata,
    rst,
    clk,
    control_out,
    Rm,
    Rn,
    Rram,
    imm_out,
    readnum_m,
    readnum_n,
    readnum_ram,
);
    parameter control_width=22;
    input [control_width-1:0] control_in;
    input [2:0] readnum_a_in;//readnum_a=Rm
    input [2:0] readnum_b_in;//readnum_b=Rn
    input [2:0] readnum_ram_in;
    input [15:0] imm_in;
    input write;
    input [2:0] writenum;
    input [15:0] writedata;
    input rst;
    input clk;

    output wire [control_width-1:0] control_out;
    output reg [15:0] Rm;
    output reg [15:0] Rn;
    output reg [15:0] Rram;
    output wire [15:0] imm_out;
    output wire [2:0] readnum_m,readnum_n,readnum_ram; //pass the read_num for future use (i.e. forwarding)
    wire [2:0] readnum_a,readnum_b; //interal wires, used between "reg nums" and "regfile"
    reg [15:0] regs [7:0]; 
    assign readnum_m = readnum_a;
    assign readnum_n = readnum_b;


    vDFF #22 control (clk,rst,control_in,control_out); //instantiate "control",    USE OF PARAMETER WILL CAUSE ERRORS!!!
    vDFF #3 reg_num_a (clk,rst,readnum_a_in,readnum_a); //instantiate "reg nums_a"
    vDFF #3 reg_num_b (clk,rst,readnum_b_in,readnum_b); //instantiate "reg nums_b"
    vDFF #3 reg_num_ram (clk,rst,readnum_ram_in,readnum_ram);
    vDFF #16 imm (clk,rst,imm_in,imm_out); //instantiate "imm"

    wire [15:0] R0,R1,R2,R3,R4,R5,R6,R7;//to be recognized by the autograder
    assign R0=regs[0];
    assign R1=regs[1];
    assign R2=regs[2];
    assign R3=regs[3];
    assign R4=regs[4];
    assign R5=regs[5];
    assign R6=regs[6];
    assign R7=regs[7];
    
    //following are the regfile

    always @(*) begin
        Rn<=regs[readnum_b];
        Rm<=regs[readnum_a];
        Rram<=regs[readnum_ram]; //for STR,Rd

    end

    always @(posedge clk) begin
        if(write) begin
            regs[writenum]<=writedata;
        end
    end

endmodule