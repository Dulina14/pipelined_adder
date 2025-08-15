module full_adder_32bit (
    input  logic [31:0] a, b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic        cout
);
    logic c1, c2, c3; // carry signals between 8-bit blocks

    // Lower 8 bits
    full_adder_8bit FA0 (a[7:0],   b[7:0],   cin, sum[7:0],   c1);

    // Bits 8-15
    full_adder_8bit FA1 (a[15:8],  b[15:8],  c1,  sum[15:8],  c2);

    // Bits 16-23
    full_adder_8bit FA2 (a[23:16], b[23:16], c2,  sum[23:16], c3);

    // Bits 24-31
    full_adder_8bit FA3 (a[31:24], b[31:24], c3,  sum[31:24], cout);
endmodule
