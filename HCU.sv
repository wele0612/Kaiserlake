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
        STALL BOTH PIPELINE S1, ADD BUBBLE in S2
    else, if
    -I5 replies on I4, or I5==STR && I4==LDR
        STALL P1, P0 moves forward.

EXAMPLES PROVIDED AT THE BUTTOM.
==================================================
*/
module HCU (
    input [2:0] p0S1_opcode,//I4 opcode
    input [5:0] p0S1_readnums,//I4 readnums
    input [2:0] p0S1_writenum,//I4 writenum
    input p0S1_write,//I4 write enable

    input [5:0] p1S1_readnums,//I5 readnums
    input [2:0] p1S1_opcode,//I5 opcode

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

    //any instruction in S1 relies on LDRs in S2 or S3
    

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