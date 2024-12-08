`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Hamim Reja
// 
// Create Date: 08.12.2024 20:20:24
// Design Name: 4-bit Arithmetic Unit with Addition, Subtraction, Multiplication, and Division
// Module Name: ALU_RTL
//////////////////////////////////////////////////////////////////////////////////

module ALU_RTL(
    input [3:0] A, B,
    input [1:0] control,
    output reg [3:0] op,
    output reg c_out
);
    parameter ADD = 2'b00, SUB = 2'b01, MUL = 2'b10, DIV = 2'b11;

    wire [3:0] sum, difference, B_compliment; // Intermediate 4-bit results
    wire carry_out, borrow;                  // Carry and borrow signals
    wire [3:0] product;                      // Product from Booth's multiplication

    // Addition
    ripple_carry_adder add(
        .A(A), 
        .B(B), 
        .c_in(1'b0), 
        .op(sum), 
        .c_op(carry_out)
    );

    // Subtraction
    assign B_compliment = ~B + 4'b0001;
    ripple_carry_adder sub(
        .A(A), 
        .B(B_compliment), 
        .c_in(1'b0), 
        .op(difference), 
        .c_op(borrow)
    );

    // Multiplication
    booths_mul mul(
        .A(A), 
        .B(B), 
        .product(product)
    );

    always @(*) begin
        op = 4'b0;       // Default value for output
        c_out = 1'b0;    // Default value for carry-out
        case (control)
            ADD: {c_out, op} = {carry_out, sum};       // Perform addition
            SUB: {c_out, op} = {borrow, difference};  // Perform subtraction
            MUL: {c_out ,op} = {1'bx , product};                        // Perform multiplication
            DIV: op = (B == 0) ? 4'bx: A / B; // Handle division, check for zero
        endcase
    end
endmodule

module ripple_carry_adder(
    input [3:0] A, B,
    input c_in,
    output [3:0] op,
    output c_op
);
    wire c1, c2, c3;
    full_adder f0(A[0], B[0], c_in, op[0], c1);
    full_adder f1(A[1], B[1], c1, op[1], c2);
    full_adder f2(A[2], B[2], c2, op[2], c3);
    full_adder f3(A[3], B[3], c3, op[3], c_op);
endmodule

module full_adder(
    input A, B, Cin,
    output sum, carry
);
    assign sum = A ^ B ^ Cin;            // XOR for sum
    assign carry = (A & B) | (B & Cin) | (A & Cin); // Carry logic
endmodule

module booths_mul(
    input [2:0] A, B,
    output reg [3:0] product
);
    reg [2:0] acc;                 // Accumulator for partial products
    reg [2:0] q;                   // Multiplier register
    reg q_1;                       // Previous bit of Q
    reg [2:0] counter;             // Counter for iterations
    reg [2:0] B_compliment;        // 2's complement of B

    always @(A, B) begin
        // Initialization
        q = A;                     
        acc = 2'b0;                 
        q_1 = 1'b0;                 
        counter = 2;                
        B_compliment = ~B + 1'b1;   

        // Booth's algorithm loop
        while (counter > 0) begin
            case ({q[0], q_1})       
                2'b01: acc = acc + B;          // Add B to accumulator
                2'b10: acc = acc + B_compliment; // Subtract B from accumulator
                2'b00, 2'b11: ;                // No operation
            endcase

            // Perform arithmetic right shift
            {acc, q, q_1} = {{acc[2]}, acc, q[2:1], q[0]}; 
            counter = counter - 1'b1;        // Decrement counter
        end

        // Combine accumulator and multiplier to form the product
        product = {acc, q};                  // 8-bit result: {accumulator, Q}
    end
endmodule
