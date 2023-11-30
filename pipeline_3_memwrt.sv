module pipeline_3_memwrt (
    control_in,N_in,V_in,Z_in,result_in,Rram_value_in,read_num_m,read_num_n,read_num_ram,rst,clk,
    result,N,V,Z,control_out,//read_num_m_out,read_num_n_out,read_num_ram_out,
    //connect to ram
    write_data_ram,addr_ram,write_ram
);
    parameter control_width=22;  
    input [control_width-1:0] control_in;
    input [2:0] read_num_m;
    input [2:0] read_num_n;
    input [2:0] read_num_ram;
    input N_in;
    input V_in;
    input Z_in;
    input [15:0] result_in;
    input [15:0] Rram_value_in;
    input rst;
    input clk;

    output [15:0] result;
    output N;
    output V;
    output Z; 
    output [control_width-1:0] control_out;
    /*
    output [2:0] read_num_m_out;
    output [2:0] read_num_n_out;
    output [2:0] read_num_ram_out;
    */
    wire [2:0] read_num_m_out,read_num_n_out,read_num_ram_out;

    //COnnect to ram
    output [15:0] write_data_ram;
    output [8:0] addr_ram;
    output write_ram;

    assign addr_ram=result;

    wire [15:0] result,Rram_value;
    wire [2:0] opcode;
    assign opcode=control_out[21:19];
    assign write_ram=(opcode==3'b100);

    vDFF #3 readnum_m (clk,rst,read_num_m,read_num_m_out);//registor number
    vDFF #3 readnum_n (clk,rst,read_num_n,read_num_n_out);
    vDFF #3 readnum_ram (clk,rst,read_num_ram,read_num_ram_out);
    vDFF #3 flags(clk,rst,{N_in,V_in,Z_in},{N,V,Z});
    vDFF #22 control (clk,rst,control_in,control_out);  //instaniation of  "control"

    vDFF #16 result_reg (clk,rst,result_in,result);
    vDFF #16 Rram_value_reg (clk,rst,Rram_value_in,Rram_value);
    assign write_data_ram=Rram_value;


endmodule