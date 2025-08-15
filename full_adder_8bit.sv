module full_adder_8bit (
    input  logic [7:0] a, b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
    assign {cout, sum} = a + b + cin;
endmodule
