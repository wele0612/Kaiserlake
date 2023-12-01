module data_forward (
    input [15:0] data_reg_in,//the data read and ready to pass to next pREG
    input [2:0] num_reg_in,  //the regnum correspond to the data

    input [15:0] data_m1_in,//result for t=-1 instruction
    input [15:0] data_m2_in,//this is the data used in forwarding
    input [15:0] data_m3_in,
    input [15:0] data_m4_in,

    input [2:0] num_m1_in,//write num for t=-1 instruction
    input [2:0] num_m2_in,//this is the write regnum in t_minus pREG
    input [2:0] num_m3_in,
    input [2:0] num_m4_in,

    input m1_write_in,// this shows if the instruction enable write in t_minus pREG
    input m2_write_in,
    input m3_write_in,
    input m4_write_in,

    output reg [15:0] data_forwarded_out
);

    reg [4:1] has_hazard;/*
    assign has_hazard[1]=(num_reg_in==num_m1_in)&&m1_write_in;
    assign has_hazard[2]=(num_reg_in==num_m2_in)&&m2_write_in;
    assign has_hazard[3]=(num_reg_in==num_m3_in)&&m3_write_in;
    assign has_hazard[4]=(num_reg_in==num_m4_in)&&m4_write_in;
    assign has_hazard[5]=(num_reg_in==num_m5_in)&&m5_write_in;
    assign has_hazard[6]=(num_reg_in==num_m6_in)&&m6_write_in;*/

    always @(*) begin
        has_hazard[1]=(num_reg_in==num_m1_in)&&m1_write_in;
        has_hazard[2]=(num_reg_in==num_m2_in)&&m2_write_in;
        has_hazard[3]=(num_reg_in==num_m3_in)&&m3_write_in;
        has_hazard[4]=(num_reg_in==num_m4_in)&&m4_write_in;
        casez (has_hazard)
            6'bzzz1: data_forwarded_out=data_m1_in;
            6'bzz10: data_forwarded_out=data_m2_in;
            6'bz100: data_forwarded_out=data_m3_in;
            6'b1000: data_forwarded_out=data_m4_in;
            default: data_forwarded_out=num_reg_in;
        endcase
    end
    
endmodule