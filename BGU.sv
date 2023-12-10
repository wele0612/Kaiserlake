module BGU (
    input [8:0] PC,
    input fetch_next_in,
    
    input clk,
    input rst,

    input N,
    input V,
    input Z,

    input [15:0] p0_IR_in,
    input [15:0] p1_IR_in,

    input p0_do_delayed_B,
    input p1_do_delayed_B,

    output [15:0] p0_delayed_B_1in,
    output [2:0] p0_delayed_cond_1in,
    output [15:0] p1_delayed_B_1in,
    output [2:0] p1_delayed_cond_1in,

    output [8:0] PC_next_out,
    output IR0_invalid_out,
    output is_p0_b,
    output reset_S1,
    output [7:0] halt_addr,
    output halted
);
    

    //wire [7:0] p0_imm,p1_imm;

    wire is_p1_b;
    
    //state machine for system halt.
    wire p0_halt_now,p1_halt_now;
    wire [7:0] p0_halt_addr,p1_halt_addr;
    vDFF REG_BGU_halt(clk,rst,p0_halt_now||p1_halt_now||halted,halted);
    //record HALT_addr when halt happens
    vDFF_en #8 REG_BGU_p0_halt_PCaddr(clk,rst,p0_halt_now,p0_IR_in[7:0],p0_halt_addr);
    vDFF_en #8 REG_BGU_p1_halt_PCaddr(clk,rst,p1_halt_now,p1_IR_in[7:0],p1_halt_addr);
    assign halt_addr=p0_halt_addr|p1_halt_addr;
    
    
    /* for following situation:
    0x04:   goto 0x11(or any odd address)
    ...
    0x10: do something
    0x11: do something

    Since PC is always even, mem will still fetch 0x10 and 0x11
    into p0 and p1. However, 0x10 should not be executed in 
    this case. 
    Therefore, we create a signal to disable p0 two periods later
    when we jump to a odd address. (IR0_invalid_out)
    (B instruction takes two period to execute)
    */

    wire [7:0] PC_prev_p1,PC_prev_p2;
    vDFF_en #8 REG_PC_PREV_p1(clk,rst,fetch_next_in,{PC[7:1],1'b1},PC_prev_p1);
    vDFF_en #8 REG_PC_PREV_p2(clk,rst,fetch_next_in,PC[7:0]+2'd2,PC_prev_p2);

    reg reset_S1_regout;
    //B works at the clk after next, clean up garbage data in pipeline before that.
    //In other words, PC will overshoot before B works. We need to prevent that.
    always @(posedge clk) begin
        if(rst)begin
            reset_S1_regout=1'b1;
        end else begin
            if (fetch_next_in) begin
                reset_S1_regout=(is_p0_b||is_p1_b);
                if(p0_delayed_cond_1in==3'd1||p1_delayed_cond_1in==3'd1)begin
                    reset_S1_regout=1'b0;
                    //If p0 and p1 have delayed Branch with condition AL,
                    //garbage instructions in S1 will be reset later by delayed branch.
                    //Resettig them here may accidentally reset delayed branches when HCU
                    //are holding it is S1.
                end
            end
        end
    end
    //When reset_S1 is 1, that means whatever instruction now is invalid
    assign reset_S1=reset_S1_regout&&fetch_next_in&&(~(p0_do_delayed_B||p1_do_delayed_B));

    //is_px_b indicates if px_IR_in is a valid branching insturction    
    assign is_p0_b=((p0_IR_in[15:13]==3'b001||p0_IR_in[15:13]==3'b010||p0_IR_in[15:13]==3'b111)
        &&(~IR0_invalid_out))&&((~reset_S1))&&(~p1_do_delayed_B);
    assign is_p1_b=((p1_IR_in[15:13]==3'b001||p1_IR_in[15:13]==3'b010||p1_IR_in[15:13]==3'b111)&&(~reset_S1));

    wire [7:0] destination;
    wire [7:0] p0_dest,p1_dest;

    wire [2:0] p0_delayed_cond_decode_result;
    branch_decode p0_B_DECODE(
        .IR_in(p0_IR_in),
        .B_format(p0_do_delayed_B),
        .prediction(1'b0),
        .PCp1_for_this(PC_prev_p1),
        .reset_S1(reset_S1_regout),

        .destination_now(p0_dest),
        .destination_delayed(p0_delayed_B_1in[7:0]),
        .instruction_delayed_head(p0_delayed_B_1in[15:8]),
        .cond_delayed(p0_delayed_cond_decode_result),
        .halt_now(p0_halt_now)
    );
    //If this is invalid, set condition to NV...
    assign p0_delayed_cond_1in=is_p0_b?p0_delayed_cond_decode_result:3'b000;
    
    wire [2:0] p1_delayed_cond_decode_result;
    branch_decode p1_B_DECODE(
        .IR_in(p1_IR_in),
        .B_format(p1_do_delayed_B),
        .prediction(1'b0),
        .PCp1_for_this(PC_prev_p2),
        .reset_S1(reset_S1_regout),

        .destination_now(p1_dest),
        .destination_delayed(p1_delayed_B_1in[7:0]),
        .instruction_delayed_head(p1_delayed_B_1in[15:8]),
        .cond_delayed(p1_delayed_cond_decode_result),
        .halt_now(p1_halt_now)
    );
    assign p1_delayed_cond_1in=is_p1_b?p1_delayed_cond_decode_result:3'b000;
    
    assign destination=is_p0_b?p0_dest:p1_dest;

    wire [8:0] PC_acc_2,PC_next;

    wire next_IR0_invalid,next_IR0_invalid_regout;
    vDFF_en REG_next_IR0_invalid(clk,rst,fetch_next_in,PC_next[0],next_IR0_invalid);
    vDFF_en REG_IR0_invalid(clk,rst,fetch_next_in,next_IR0_invalid,next_IR0_invalid_regout);
    assign IR0_invalid_out=next_IR0_invalid_regout&&(~p0_do_delayed_B);
    //in case the pipeline stalls, we nned to know the correct "next PC"\
    //just before it stall, and use it to update PC when stall is gone

    assign PC_acc_2={{PC[8:1]+1'b1},PC[0]};//PC plus 2, next inst

    assign PC_next={(is_p0_b||is_p1_b)?destination:PC_acc_2};
    assign PC_next_out={PC_next[8:1],1'b0};//PC should be even
    
endmodule
/*Implementation of HALT
    Default HALT: 111 000000000000
    HALT_immediately 001 00 111 [PC_of_HALT+1]

    Default HALT is ISA should wait untill all instructions before HALT are done,
    then HALT. We also want to record the value of PC+1 of HALT.
    This is very similar to the behavior of delayed Branch.
    Therefore, we decode HALT as a delayed HALT_immediately(encoded as B with cond 111).

    When HALT_immediately comes back to BGU, instruction fetch stops and halt signal is on.
*/

/*Process dealing with conditional branches
0). We convert BLE, BLT, BEQ... To a pair of unconditional branches.
    For example, BEQ imm->
            [A] goto pc+1+imm (if EQ)
            [B] goto pc+1     (if NE)
    Unconditioned B will be like this:
    B imm->
            [A] goto pc+1+imm (if AL)
            [B] goto pc+1     (if NV)
    Function call will be like this:
    BL(X) imm->
            [A] goto pc+1+imm (if NV)  //this imm actually makes no sense.
            [B] goto pc+1+?   (if AL)  Will have calculation later, is not final
1). BGU is fine dealing with unconditioned B.
    We can feed one of converted branch into BGU, the other into delayed.
    Later Stage3 of pipeline, if conditions for delayed branches are met,
        pipeline will cleanup and do the delayed one.
    
2). For the delayed one, we need to save its destination address. Since we don't
    know what PC will be when the delayed one happens.
3). When deciding which to feed into which, we can use a fixed decision or prediction. 

The following module does 0).
*/
module branch_decode (
    input [15:0] IR_in,
    input B_format,//1=B dest,0=B imm
    input prediction,
    input [7:0] PCp1_for_this,//PC plus 1 for this
    input reset_S1,

    output [7:0] destination_now,
    output [7:0] destination_delayed,
    output reg [7:0] instruction_delayed_head,
    output [2:0] cond_delayed,
    output reg halt_now
);
    parameter NV=3'd0,
            AL=3'd1,
            EQ=3'd2,
            NE=3'd3,
            LT=3'd4,
            LE=3'd5,
            GT=3'd6,
            GE=3'd7;

    wire [7:0] dest_ifB; //destination if branch
    wire [7:0] imm;
    assign imm=IR_in[7:0];
    assign dest_ifB=B_format?
        imm:(PCp1_for_this+imm);//if B_format is 0, it is the destination already.

    wire [7:0] dest_ifnB;
    assign dest_ifnB=PCp1_for_this;

    reg take_B_now;
    wire [2:0] cond,opcode;
    assign cond=IR_in[10:8];
    assign opcode=IR_in[15:13];
    reg [2:0] cond_ifB,cond_ifnB;

    //Decode branch
    always @(*) begin
        instruction_delayed_head=8'b001_00_000;
        halt_now=1'b0;
        take_B_now=1'b1;
        cond_ifB=AL;//Defalut: branch will always happen
        cond_ifnB=NV;//Defalut: not branch will never happen
        if(opcode==3'b001&&cond==3'b000) begin
            //if unconditioned branch,use [A] branched for now.
            take_B_now=1'b1;
            cond_ifB=AL;
            cond_ifnB=NV;
        end else if (opcode==3'b001) begin
            //if conditioned branch, use prediction.
            take_B_now=prediction;
            //set conditions!
            case (cond)
                3'b001: begin//BEQ
                    cond_ifB=EQ;
                    cond_ifnB=NE;
                end 
                3'b010: begin//BNE
                    cond_ifB=NE;
                    cond_ifnB=EQ;
                end
                3'b011: begin//BLT
                    cond_ifB=LT;
                    cond_ifnB=GE;
                end
                3'b100: begin//BLE
                    cond_ifB=LE;
                    cond_ifnB=GT;
                end
                3'b111: begin//HALT_immdiately
                    halt_now=B_format&&(~reset_S1);//May overshoot to data/invalid
                end
                default: begin
                    cond_ifB=AL;
                    cond_ifnB=NV;
                end
            endcase
        end else if (opcode==3'b010) begin
            //BL, BX and BLX are using delayed pipeline
            //So that unbranched [B] carrying PC+1 can be sent into pipeline.
            //We will calculate function destination in pipeline
            take_B_now=1'b1;
            case (IR_in[12:11])
                2'b11: begin//BL
                    take_B_now=1'b1;
                    cond_ifB=AL;
                    cond_ifnB=NV;
                end
                2'b00,2'b10: begin
                    take_B_now=1'b1;
                    cond_ifB=NV;
                    cond_ifnB=AL;
                end
                default: begin
                    cond_ifB=AL;
                    cond_ifnB=NV;
                end
            endcase
        end else if (opcode==3'b111) begin//HALT
            cond_ifnB=AL;
            cond_ifB=NV;
            take_B_now=1'b1;
            instruction_delayed_head=8'b001_00_111;
            //ifnB is carrying PC+1, send ifnB as delayed.
        end
    end

    assign destination_now=take_B_now?dest_ifB:dest_ifnB;

    assign destination_delayed=take_B_now?dest_ifnB:dest_ifB;
    assign cond_delayed=take_B_now?cond_ifnB:cond_ifB;

    
endmodule