module BGU (
    input [8:0] PC,
    input fetch_next_in,

    output [8:0] PC_next
);

    wire [8:0] PC_acc_2;
    assign PC_acc_2={{PC[8:1]+1'b1},PC[0]};//PC plus 2, next inst

    assign PC_next=fetch_next_in?PC_acc_2:PC;
    
endmodule