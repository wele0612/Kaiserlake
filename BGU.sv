module BGU (
    input [8:0] PC,
    input fetch_next_in,
    
    input clk,
    input rst,

    input [15:0] p0_IR_in,
    input [15:0] p1_IR_in,

    output [8:0] PC_next_out,
    output IR0_invalid_out,
    output is_p0_b,
    output reg reset_S1
);
    wire [7:0] p0_imm,p1_imm;
    wire is_p1_b;
    assign p0_imm=p0_IR_in[7:0];
    assign p1_imm=p1_IR_in[7:0];
    
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

    //B works at the clk after next, clean up garbage data in pipeline before that.
    //vDFF REG_reset_S1_next_clk(clk,rst,(is_p0_b||is_p1_b),reset_S1);
    always @(posedge clk) begin
        if(rst)begin
            reset_S1=1'b1;
        end else begin
            if (fetch_next_in) begin
                reset_S1=(is_p0_b||is_p1_b);
            end
        end
    end
    //Of reset_S1 is 1, that means whatever instruction now is invalid
    //assign reset_S1=0;

    
    assign is_p0_b=(p0_IR_in[15:13]==3'b001&&(~IR0_invalid_out)&&(~reset_S1));
    assign is_p1_b=(p1_IR_in[15:13]==3'b001&&(~reset_S1));

    wire [7:0] destination;
    wire [7:0] p0_dest,p1_dest;
    assign p0_dest=p0_imm+PC_prev_p1;//destination if p0 is B
    assign p1_dest=p1_imm+PC_prev_p2;//destination if p1 is B
    assign destination=is_p0_b?p0_dest:p1_dest;

    wire [8:0] PC_acc_2,PC_next;

    wire next_IR0_invalid;
    vDFF_en REG_next_IR0_invalid(clk,rst,fetch_next_in,PC_next[0],next_IR0_invalid);
    vDFF_en REG_IR0_invalid(clk,rst,fetch_next_in,next_IR0_invalid,IR0_invalid_out);
    
    vDFF_en REG_prev_nextPC();
    //in case the pipeline stalls, we nned to know the correct "next PC"\
    //just before it stall, and use it to update PC when stall is gone

    assign PC_acc_2={{PC[8:1]+1'b1},PC[0]};//PC plus 2, next inst

    assign PC_next={(is_p0_b||is_p1_b)?destination:PC_acc_2};
    assign PC_next_out={PC_next[8:1],1'b0};//PC should be even
    
endmodule