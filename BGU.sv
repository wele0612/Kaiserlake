module BGU (
    input [7:0] PC,
    input fetch_next_in,

    output [7:0] PC_next
);

    wire [7:0] PC_acc_2;
    assign PC_acc_2={{PC[7:1]+1},PC[0]};

    assign PC_next=fetch_next_in?PC_acc_2:PC;
    
endmodule