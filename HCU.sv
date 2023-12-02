/* Hazard Control Unit. Luoling 2023/12/1
-stall the pipeline and insert bubbles 
when data hazard cannot be resolved by forwarding.

   |    S0    |    S1     |   S2    |   S3     |    S4 
   |__DECODE__|__REGFILE__|__EXEC___|__MEMWRT__|__REGWRT__...
P0 |    I6    |     I4    |    I2   |   I0     |    ...
P1 |    I7    |     I5    |    I3   |   I1     |    ...
==================================================
if 
    -any instruction in S1 relies on LDRs in S2 or S3:
        STALL S1 OF BOTH PIPELINE, ADD BUBBLE in S2
    else, if
    -I5 relies on I4, or I5==STR && I4==LDR
        STALL P1, P0 moves forward.

EXAMPLES PROVIDED AT THE BUTTOM.
==================================================
*/
module HCU (
    input [2:0] p0S1_opcode,//I4 opcode
    input [8:0] p0S1_readnums,//I4 readnums, Rm-Rn-Rd
    input [2:0] p0S1_writenum,//I4 writenum
    input p0S1_write,//I4 write enable
    input [2:0] p0S1_used_RmRnRd,

    input [8:0] p1S1_readnums,//I5 readnums
    input [2:0] p1S1_opcode,//I5 opcode
    input [2:0] p1S1_used_RmRnRd,

    input [2:0] p0S2_opcode,//I2 opcode
    input [2:0] p0S2_writenum,
    input p0S2_write,

    input [2:0] p1S2_opcode,//I3 opcode
    input [2:0] p1S2_writenum,
    input p1S2_write,

    input [2:0] p0S3_opcode,//I0 opcode
    input [2:0] p0S3_writenum,
    input p0S3_write,

    input [2:0] p1S3_opcode,//I1 opcode
    input [2:0] p1S3_writenum,
    input p1S3_write,

    output reg p0_update1_out,//If I4 move forward
    output reg p1_update1_out,//If I5 move forward
    output reg [4:1] p0_rst_HCUout,//High to generate bubbles
    output reg [4:1] p1_rst_HCUout,
    output reg fetch_next//If we can fetch the next instruction
);
    parameter LDR = 3'b011,
            STR = 3'b100;
/*
   |    S0    |    S1     |   S2    |   S3     |    S4 
   |__DECODE__|__REGFILE__|__EXEC___|__MEMWRT__|__REGWRT__...
P0 |    I6    |     I4    |    I2   |   I0     |    ...
P1 |    I7    |     I5    |    I3   |   I1     |    ...
*/
    //any instruction in S1 relies on LDRs in S2 or S3
    wire [2:0] opcode [5:0];
    assign opcode[5]=p1S1_opcode;
    assign opcode[4]=p0S1_opcode;
    assign opcode[3]=p1S2_opcode;
    assign opcode[2]=p0S2_opcode;
    assign opcode[1]=p1S3_opcode;
    assign opcode[0]=p0S3_opcode;
    wire [4:0] write;
    assign write[4]=p0S1_write;
    assign write[3]=p1S2_write;
    assign write[2]=p0S2_write;
    assign write[1]=p1S3_write;
    assign write[0]=p0S3_write;
    wire [2:0] writenum [4:0];
    assign writenum[4]=p0S1_writenum;
    assign writenum[3]=p1S2_writenum;
    assign writenum[2]=p0S2_writenum;
    assign writenum[1]=p1S3_writenum;
    assign writenum[0]=p0S3_writenum;

    wire [2:0] I4_Rm=p0S1_readnums[8:6];
    wire [2:0] I4_Rn=p0S1_readnums[5:3];
    wire [2:0] I4_Rd=p0S1_readnums[2:0];
    wire I4_Rm_conflict_LDR,I4_Rn_conflict_LDR,I4_Rd_conflict_LDR;
    wire I4_conflict_LDR;
    assign I4_conflict_LDR=I4_Rm_conflict_LDR||I4_Rn_conflict_LDR||I4_Rd_conflict_LDR;
    assign I4_Rm_conflict_LDR=p0S1_used_RmRnRd[2]&&{
        {I4_Rm==writenum[3]&&opcode[3]==LDR}||
        {I4_Rm==writenum[2]&&opcode[2]==LDR}||
        {I4_Rm==writenum[1]&&opcode[1]==LDR}||
        {I4_Rm==writenum[0]&&opcode[0]==LDR}};

    assign I4_Rn_conflict_LDR=p0S1_used_RmRnRd[1]&&{
        {I4_Rn==writenum[3]&&opcode[3]==LDR}||
        {I4_Rn==writenum[2]&&opcode[2]==LDR}||
        {I4_Rn==writenum[1]&&opcode[1]==LDR}||
        {I4_Rn==writenum[0]&&opcode[0]==LDR}};

    assign I4_Rd_conflict_LDR=p0S1_used_RmRnRd[0]&&{
        {I4_Rd==writenum[3]&&opcode[3]==LDR}||
        {I4_Rd==writenum[2]&&opcode[2]==LDR}||
        {I4_Rd==writenum[1]&&opcode[1]==LDR}||
        {I4_Rd==writenum[0]&&opcode[0]==LDR}};

    wire [2:0] I5_Rm=p1S1_readnums[8:6];
    wire [2:0] I5_Rn=p1S1_readnums[5:3];
    wire [2:0] I5_Rd=p1S1_readnums[2:0];
    wire I5_Rm_conflict_LDR,I5_Rn_conflict_LDR,I5_Rd_conflict_LDR;
    wire I5_conflict_LDR;
    assign I5_conflict_LDR=I5_Rm_conflict_LDR||I5_Rn_conflict_LDR||I5_Rd_conflict_LDR;
    assign I5_Rm_conflict_LDR=p1S1_used_RmRnRd[2]&&{
        {I5_Rm==writenum[3]&&opcode[3]==LDR}||
        {I5_Rm==writenum[2]&&opcode[2]==LDR}||
        {I5_Rm==writenum[1]&&opcode[1]==LDR}||
        {I5_Rm==writenum[0]&&opcode[0]==LDR}};

    assign I5_Rn_conflict_LDR=p1S1_used_RmRnRd[1]&&{
        {I5_Rn==writenum[3]&&opcode[3]==LDR}||
        {I5_Rn==writenum[2]&&opcode[2]==LDR}||
        {I5_Rn==writenum[1]&&opcode[1]==LDR}||
        {I5_Rn==writenum[0]&&opcode[0]==LDR}};

    assign I5_Rd_conflict_LDR=p1S1_used_RmRnRd[0]&&{
        {I5_Rd==writenum[3]&&opcode[3]==LDR}||
        {I5_Rd==writenum[2]&&opcode[2]==LDR}||
        {I5_Rd==writenum[1]&&opcode[1]==LDR}||
        {I5_Rd==writenum[0]&&opcode[0]==LDR}};

    wire I5_Rm_rely_I4,I5_Rn_rely_I4,I5_Rd_rely_I4;
    assign I5_Rm_rely_I4={I5_Rm==writenum[4]&&write[4]&&p1S1_used_RmRnRd[2]};
    assign I5_Rn_rely_I4={I5_Rn==writenum[4]&&write[4]&&p1S1_used_RmRnRd[1]};
    assign I5_Rd_rely_I4={I5_Rd==writenum[4]&&write[4]&&p1S1_used_RmRnRd[0]};
    wire I5_rely_I4;
    assign I5_rely_I4=I5_Rm_rely_I4||I5_Rn_rely_I4||I5_Rd_rely_I4;

    wire I5STR_I4LDR;
    assign I5STR_I4LDR=(opcode[5]==STR)&&(opcode[4]==LDR);

    always @(*) begin
        p0_update1_out=1'b1;
        p1_update1_out=1'b1;
        p0_rst_HCUout=4'b0;
        p1_rst_HCUout=4'b0;
        fetch_next=1'b1;
        if (I4_conflict_LDR||I5_conflict_LDR) begin
            p0_update1_out=1'b0;//stall
            p1_update1_out=1'b0;//stall
            p0_rst_HCUout[2]=1'b1;//Add bubble
            p1_rst_HCUout[2]=1'b1;//Add bubble
            fetch_next=1'b0;
        end else if (I5STR_I4LDR||I5_rely_I4) begin
            p1_update1_out=1'b0;
            p0_rst_HCUout[1]=1'b1;
            p1_rst_HCUout[2]=1'b1;
            fetch_next=1'b0;
        end
    end
    

endmodule

/*
">" indicate forwarded data
==================================================
Case 0: if I5 depends on I4
    -DO NOT fetch new instructions
    -stalled S0
    -stalled P1_S1
    -insert bubble on P1_S2
    -insert bubble on P0_S1
in next posedge clk:
   |    S0    |    S1     |   S2    |   S3     |
   |__DECODE__|__REGFILE__|__EXEC___|__MEMWRT__|__...
P0 |    I6    |           |    I4   |   I2     |
P1 |    I7    |     I5   >|         |   I3     |

I5 can now forward I4.
==================================================
Case 1: if instructions in S1 depend on LDRs in S3:
    -DO NOT fetch new instructions
    -stalled S0,S1
    -insert bubbles on S2
in next posedge clk:
   |    S0    |    S1     |   S2    |   S3     |    S4 
   |__DECODE__|__REGFILE__|__EXEC___|__MEMWRT__|__REGWRT__...
P0 |    I6    |     I4   >|         |   I2     |  I0[LDR]
P1 |    I7    |     I5   >|         |   I3     |  I1[LDR]

LDRs have now fetched the data. Data can be forwarded to I4/I5.
==================================================
Case 2: if instruction in S1 depend on LDRs in S2:
    -Take action in case 1.
in next posedge clk:
   |    S0    |    S1     |   S2    |   S3     |    S4 
   |__DECODE__|__REGFILE__|__EXEC___|__MEMWRT__|__REGWRT__...
P0 |    I6    |     I4    |         |  I2[LDR] |    I0
P1 |    I7    |     I5    |         |  I3[LDR] |    I1

We are now in Case 1.
==================================================
Case 3: if I5 depends on I4, which is a LDR，
    or if I5 is STR, and I4 is LDR:
    -Take action in case 0.
in next posedge clk:
    -We may have no problem or we may be in case 1.
*/