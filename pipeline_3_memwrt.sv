module pipeline_3_memwrt (
    input [21:0] control_in,
    input [15:0] data_Rd_in,
    input highbit_shifted_Rm_in,
    input highbit_data_Rn_in,
    input [15:0] result_in,
    input [5:0] inst_type_in,
    input [15:0] delayed_B_in,
    input [2:0] delayed_cond_in,
    input S4_do_delayed_B,
    input S3_do_delayed_B,
    input N_in,
    input V_in,
    input Z_in,//We may use flags from the other pipeline, so...
    //this input one should be the correct one.

    input rst,
    input clk,

    output [15:0] result_out,
    output N_out,
    output reg V_out,
    output Z_out, 
    output [21:0] control_out,
    output [5:0] inst_type_out,
    output [15:0] delayed_B_out,
    output reg do_delayed_B,

    //Connect to ram
    output [15:0] wdata_mem,
    output [8:0] addr_mem,
    output write_mem
);
    wire [15:0] data_Rd;
    //If delayed branch happens next clk, this STR is invalid, so
    //DO NOT WRITE TO MEM!
    assign write_mem=inst_type_out[1]&&(~S4_do_delayed_B);//is opcode STR?

    wire loads=control_in[8]&&(~rst);
    wire [2:0] delayed_cond;
    parameter NV=3'd0,
            AL=3'd1,
            EQ=3'd2,
            NE=3'd3,
            LT=3'd4,
            LE=3'd5,
            GT=3'd6,
            GE=3'd7;

    vDFF_nr #16 pREG_delayed_B (clk,delayed_B_in,delayed_B_out);
    vDFF #3 pREG_delayed_cond (clk,rst,delayed_cond_in,delayed_cond);

    always @(*) begin
        case (delayed_cond)
            NV: do_delayed_B=1'b0;
            AL: do_delayed_B=1'b1;
            EQ: do_delayed_B=Z_in;
            NE: do_delayed_B=~Z_in;
            LT: do_delayed_B=(N_in!=V_in);
            LE: do_delayed_B=(N_in!=V_in)||Z_in;
            GT: do_delayed_B=~((N_in!=V_in)||Z_in);
            GE: do_delayed_B=(N_in==V_in);//~LT
            default: do_delayed_B=1'b0;
        endcase
    end

    vDFF #22 pREG_control (clk,rst,control_in,control_out);
    vDFF_nr #16 pREG_result (clk,result_in,result_out);
    vDFF_nr #16 pREG_data_Rd (clk,data_Rd_in,data_Rd);
    vDFF #6 pREG_inst_type (clk,rst,inst_type_in,inst_type_out);
    assign wdata_mem=data_Rd;
    assign addr_mem=result_out[8:0];

    wire highbit_shifted_Rm,highbit_data_Rn;
    wire [15:0] result_for_flag;
    vDFF_ennr #18 flagREG(clk,loads,
        {highbit_shifted_Rm_in,highbit_data_Rn_in,result_in},
        {highbit_shifted_Rm,highbit_data_Rn,result_for_flag});

        assign N_out=result_for_flag[15];
        assign Z_out=~(|result_for_flag);
    
    always @(*) begin
        case ({highbit_data_Rn,highbit_shifted_Rm,result_for_flag[15]})//OVERFLOW
        3'b011,3'b100:  V_out=1'b1; //(+ minus - = -) or (- minus + = +)
        default: V_out=1'b0;
    endcase
    end

endmodule