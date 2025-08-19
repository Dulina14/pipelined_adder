// module pipelined32bit_adder(
//     input  logic        clk, rstn,
//     input  logic [31:0] num1 [3 : 0], num2 [3 : 0],
//     input  logic        cin,
//     output logic [31:0] C,
//     output logic        cout
// );

//     // Pipeline registers (renamed for clarity)
//     logic [31:0] A, B;
//     logic [7:0] sum_stage1, sum_stage2, sum_stage3, sum_stage4, sum_stage5, sum_stage6;
//     logic [7:0] buffer1, buffer2, buffer3, buffer4, buffer5, buffer6;
//     logic [7:0] buffer7, buffer8, buffer9, buffer10, buffer11, buffer12;
//     logic       carry_stage1, carry_stage2, carry_stage3;

//     always_ff @(negedge clk or negedge rstn ) begin
//         num1[0] <= num1 [1]; num2[0] <= num2 [1];
//         num1[1] <= num1 [2]; num2[1] <= num2 [2];
//         num1[2] <= num1 [3]; num2[2] <= num2 [3];
//         A <= num1 [0]; B <= num2 [0];
//     end

//     // Stage 1: Add lowest 8 bits
//     full_adder_8bit adder1 (
//         .num1(A[7:0]),
//         .num2(B[7:0]),
//         .cin(0),
//         .sum(sum_stage1),
//         .cout(carry_stage1)
//     );

//     // Stage 2: Next 8 bits
//     full_adder_8bit adder2 (
//         .num1(buffer1),
//         .num2(buffer2),
//         .cin(carry_stage1),
//         .sum(sum_stage4),
//         .cout(carry_stage2)
//     );

//     // Stage 3: Next 8 bits
//     full_adder_8bit adder3 (
//         .num1(buffer5),
//         .num2(buffer6),
//         .cin(carry_stage2),
//         .sum(sum_stage6),
//         .cout(carry_stage3)
//     );

//     // Stage 4: Highest 8 bits
//     full_adder_8bit adder4 (
//         .num1(buffer11),
//         .num2(buffer12),
//         .cin(carry_stage3),
//         .sum(C[31:24]),
//         .cout(cout)
//     );

//     always @(negedge clk or negedge rstn) begin
//         if(!rstn) begin
//             sum_stage1 <= 0; sum_stage2 <= 0; sum_stage3 <= 0; sum_stage4 <= 0; sum_stage5 <= 0; sum_stage6 <= 0;
//             buffer1 <= 0; buffer2 <= 0; buffer3 <= 0; buffer4 <= 0; buffer5 <= 0; buffer6 <= 0;
//             buffer7 <= 0; buffer8 <= 0; buffer9 <= 0; buffer10 <= 0; buffer11 <= 0; buffer12 <= 0;
//         end else begin

//             buffer1 <= A[15 : 8]; buffer2 <= B[15:8];

//             buffer5 <= buffer3  ; buffer6 <= buffer4;
//             buffer3 <= A[23: 16]; buffer4 <= B[23: 16];

//             buffer11 <= buffer9 ; buffer12 <= buffer10;
//             buffer9 <= buffer7 ; buffer10 <= buffer8;
//             buffer7 <= A[31: 24]; buffer8 <= B[31:24];

//             sum_stage2 <= sum_stage1;
//             sum_stage3 <= sum_stage2;
//             C[7:0] <= sum_stage3;

//             sum_stage5  <= sum_stage4;
//             C[15 : 8]   <= sum_stage5;

//             C[16 : 23]  <= sum_stage6;

//         end

//     end

// endmodule

module pipeline_adder_32bit(
    input clk,
    input reset,
    input [31:0] a, b,
    input cin,
    output [31:0] sum,
    output cout
);

    // Internal wires for carry propagation
    wire [2:0] c;
    wire [31:0] s;
    
    // Pipeline registers for Level 1 (bits 7:0)
    reg [7:0] r1, r2, r3;
    
    // Pipeline registers for Level 2 (bits 15:8)
    reg [7:0] s1, s2, s3, s4;
    reg a1;
    
    // Pipeline registers for Level 3 (bits 23:16)
    reg [7:0] t1, t2, t3, t4, t5;
    reg a2;
    
    // Pipeline registers for Level 4 (bits 31:24)
    reg [7:0] u1, u2, u3, u4, u5, u6;
    reg a3;
    
    // First 8-bit adder (bits 7:0) - combinational
    full_adder_8bit FA1(
        .num1(a[7:0]),
        .num2(b[7:0]),
        .cin(cin),
        .sum(s[7:0]),
        .cout(c[0])
    );
    
    // Second 8-bit adder (bits 15:8) - uses pipelined inputs
    full_adder_8bit FA2(
        .num1(s1),
        .num2(s2),
        .cin(a1),
        .sum(s[15:8]),
        .cout(c[1])
    );
    
    // Third 8-bit adder (bits 23:16) - uses pipelined inputs
    full_adder_8bit FA3(
        .num1(t3),
        .num2(t4),
        .cin(a2),
        .sum(s[23:16]),
        .cout(c[2])
    );
    
    // Fourth 8-bit adder (bits 31:24) - uses pipelined inputs
    full_adder_8bit FA4(
        .num1(u5),
        .num2(u6),
        .cin(a3),
        .sum(sum[31:24]),
        .cout(cout)
    );
    
    // Pipeline register updates
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline registers
            r1 <= 8'b0; r2 <= 8'b0; r3 <= 8'b0;
            s1 <= 8'b0; s2 <= 8'b0; s3 <= 8'b0; s4 <= 8'b0;
            t1 <= 8'b0; t2 <= 8'b0; t3 <= 8'b0; t4 <= 8'b0; t5 <= 8'b0;
            u1 <= 8'b0; u2 <= 8'b0; u3 <= 8'b0; u4 <= 8'b0; u5 <= 8'b0; u6 <= 8'b0;
            a1 <= 1'b0; a2 <= 1'b0; a3 <= 1'b0;
        end
        else begin
            // Pipeline Stage 1: Process bits 7:0
            r1 <= s[7:0];      // Store result from FA1
            r2 <= r1;          // Pipeline delay
            r3 <= r2;          // Pipeline delay (output stage)
            
            // Pipeline Stage 2: Process bits 15:8
            s1 <= a[15:8];     // Input operand A bits 15:8
            s2 <= b[15:8];     // Input operand B bits 15:8
            a1 <= c[0];        // Carry from FA1
            s3 <= s[15:8];     // Result from FA2
            s4 <= s3;          // Pipeline delay (output stage)
            
            // Pipeline Stage 3: Process bits 23:16
            t1 <= a[23:16];    // Input operand A bits 23:16
            t2 <= b[23:16];    // Input operand B bits 23:16
            t3 <= t1;          // Pipeline delay
            t4 <= t2;          // Pipeline delay
            a2 <= c[1];        // Carry from FA2
            t5 <= s[23:16];    // Result from FA3 (output stage)
            
            // Pipeline Stage 4: Process bits 31:24
            u1 <= a[31:24];    // Input operand A bits 31:24
            u2 <= b[31:24];    // Input operand B bits 31:24
            u3 <= u1;          // Pipeline delay
            u4 <= u2;          // Pipeline delay
            u5 <= u3;          // Pipeline delay
            u6 <= u4;          // Pipeline delay
            a3 <= c[2];        // Carry from FA3
        end
    end
    
    // Assign outputs from pipeline registers
    assign sum[7:0]   = r3;      // Lowest byte output (3 clock cycles delay)
    assign sum[15:8]  = s4;      // Second byte output (2 clock cycles delay)
    assign sum[23:16] = t5;      // Third byte output (1 clock cycle delay)
    // sum[31:24] is directly connected to FA4 output (0 clock cycles delay)
    
endmodule