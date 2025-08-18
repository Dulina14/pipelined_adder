module full_adder_8bit(
        input [7:0]num1,num2,
        input cin,
        output [7:0]sum,
        output cout
        );
    
    wire    [8:0] sum_complete;
    assign  sum_complete = {1'b0, num1} + {1'b0, num2} + {7'b0, cin};
    assign  sum = sum_complete[7:0];
    assign  cout = sum_complete[8];
endmodule
