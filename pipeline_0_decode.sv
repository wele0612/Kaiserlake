module pipeline_0_decode (
    in,load,rst,clk,
    control_out,Rm,Rn,sximm,Rram
);
    parameter control_width=22;
    input [15:0] in;
    input load;
    input rst;
    input clk;

    output [21:0] control_out;
    output reg [2:0] Rm;//Rm
    output reg [2:0] Rn;//Rn
    output reg [15:0] sximm; 
    output reg [2:0] Rram;// this is for Rd in STR

    wire [15:0] IR_out;
    wire [15:0] IR_in;
    assign IR_in=load?in:16'b0;
    vDFF #(16) IR(clk,rst,IR_in,IR_out);//instruction registor
    wire [2:0] opcode;
    assign opcode=IR_out[15:13];

    reg [7:0] PC;
    reg asel,bsel,loads;
    reg [1:0] ALUop;
    reg [1:0] shift;
    reg write;
    reg [2:0] writenum;
    assign control_out={opcode,{PC},asel,bsel,loads,ALUop,shift,write,writenum};
    //assign control_out = { {control_width - 3{1'b0}}, opcode, {PC}, asel, bsel, loads, ALUop, shift, write, writenum };
    //assign control_out[2:0]=writenum;
    //assign control_out[3]=write;

    always @(*) begin//instruction decoder
        PC=8'b0;//RESERVED FOR FUTURE FUNCTIONS
        asel=1'b0;
        bsel=1'b0;
        loads=1'b0;
        ALUop=2'b0;
        shift=2'b0;
        write=0;
        writenum=3'b0;

        Rram=3'b0;
        Rm=3'b0;
        Rn=3'b0;
        sximm=16'b0;

        case (opcode)
            3'b000: write=0;//NOP

            3'b110: begin//MOV
                if(IR_out[12:11]==2'b10) begin//MOV IMM
                    asel=1'b1;
                    bsel=1'b1;
                    shift=2'b00;
                    ALUop=2'b00; //final result will be imm8+0
                    sximm={{9{IR_out[7]}},IR_out[6:0]};
                    writenum=IR_out[10:8];//set writeback
                end else begin//MOV REG
                    writenum=IR_out[7:5];//set Rd
                    shift=IR_out[4:3];//set shift
                    Rm=IR_out[2:0];//set Rm
                    sximm=16'b0;
                    ALUop=2'b00;
                    bsel=1'b1;
                end
                write=1'b1;//Enable writeback
            end

            3'b101: begin
                ALUop=IR_out[12:11];
                case (ALUop)
                    2'b00,2'b10: begin//ADD,AND
                        Rn=IR_out[10:8];
                        writenum=IR_out[7:5];
                        write=1;
                        shift=IR_out[4:3];
                        Rm=IR_out[2:0];
                    end 

                    2'b01: begin//CMP
                        write=0;//No write back
                        Rn=IR_out[10:8];
                        shift=IR_out[4:3];
                        Rm=IR_out[2:0];
                        loads=1;//Set the flag
                    end

                    2'b11: begin//MVN
                        write=1;//Enable writeback
                        writenum=IR_out[7:5];
                        shift=IR_out[4:3];
                        Rm=IR_out[2:0];
                    end
                    default: write=0;
                endcase
            end

            3'b100:begin //STR
                bsel=1'b1;
                Rm=IR_out[10:8];
                sximm={{12{IR_out[4]}},IR_out[3:0]};
                Rram=IR_out[7:5];
            end

            3'b011:begin //LDR
                bsel=1'b1;
                Rm=IR_out[10:8];
                sximm={{12{IR_out[4]}},IR_out[3:0]};
                write=1'b1;
                writenum=IR_out[7:5];
            end

            default: write=0;
        endcase

    end
    
endmodule
