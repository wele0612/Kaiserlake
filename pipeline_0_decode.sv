/*
pipeline stage 0
A combinational logic to convert instruction into control signals
INPUT: instruction and its addr(PC)
*/
module pipeline_0_decode (
    input [15:0] IR_in,
    input [7:0] PC,

    output [21:0] control_out,
    output reg [2:0] num_Rm,//num_Rm
    output reg [2:0] num_Rn,//num_Rn
    output reg [2:0] num_Rd,// this is for Rd in STR

    //if these registers are taken as input parameters
    //i.e. will the initial value of them affect the result?
    output reg [2:0] used_RmRnRd_out,
    
    output reg [15:0] sximm
);
    wire [2:0] opcode;
    assign opcode=IR_in[15:13];
    
    reg asel,bsel,loads;
    reg [1:0] ALUop;
    reg [1:0] shift;
    reg write;
    reg [2:0] writenum;
    assign control_out={opcode,{PC},asel,bsel,loads,ALUop,shift,write,writenum};

    always @(*) begin//instruction decoder
        asel=1'b0;
        bsel=1'b0;
        loads=1'b0;
        ALUop=2'b0;
        shift=2'b0;
        write=0;
        writenum=3'b0;
        used_RmRnRd_out=3'b0;

        num_Rd=3'b0;
        num_Rm=3'b0;
        num_Rn=3'b0;
        sximm=16'b0;

        case (opcode)
            3'b000: write=0;//NOP

            3'b110: begin//MOV
                if(IR_in[12:11]==2'b10) begin//MOV IMM
                    asel=1'b1;
                    bsel=1'b1;
                    shift=2'b00;
                    ALUop=2'b00; //final result will be imm8+0
                    sximm={{9{IR_in[7]}},IR_in[6:0]};
                    writenum=IR_in[10:8];//set writeback

                    used_RmRnRd_out=3'b000;
                end else begin//MOV REG
                    writenum=IR_in[7:5];//set Rd
                    shift=IR_in[4:3];//set shift
                    num_Rm=IR_in[2:0];//set num_Rm
                    sximm=16'b0;
                    ALUop=2'b00;
                    bsel=1'b1;

                    used_RmRnRd_out=3'b100;
                end
                write=1'b1;//Enable writeback
            end

            3'b101: begin
                ALUop=IR_in[12:11];
                if (ALUop==2'b11) begin//MVN
                    used_RmRnRd_out=3'b100;
                end else begin//ADD,AND,CMP
                    used_RmRnRd_out=3'b110;
                end
                case (ALUop)
                    2'b00,2'b10: begin//ADD,AND
                        num_Rn=IR_in[10:8];
                        writenum=IR_in[7:5];
                        write=1;
                        shift=IR_in[4:3];
                        num_Rm=IR_in[2:0];
                    end 

                    2'b01: begin//CMP
                        write=0;//No write back
                        num_Rn=IR_in[10:8];
                        shift=IR_in[4:3];
                        num_Rm=IR_in[2:0];
                        loads=1;//Set the flag
                    end

                    2'b11: begin//MVN
                        write=1;//Enable writeback
                        writenum=IR_in[7:5];
                        shift=IR_in[4:3];
                        num_Rm=IR_in[2:0];
                    end
                    default: write=0;
                endcase
            end

            3'b100:begin //STR
                bsel=1'b1;
                num_Rm=IR_in[10:8];//Rm is replacing Rn in STR only
                //becase we need to compute R[Rn]+imm
                sximm={{12{IR_in[4]}},IR_in[3:0]};
                num_Rd=IR_in[7:5];

                used_RmRnRd_out=3'b011;
            end

            3'b011:begin //LDR
                bsel=1'b1;
                num_Rm=IR_in[10:8];
                sximm={{12{IR_in[4]}},IR_in[3:0]};
                write=1'b1;
                writenum=IR_in[7:5];

                used_RmRnRd_out=3'b011;
            end

            default: write=0;
        endcase

    end
    
endmodule
