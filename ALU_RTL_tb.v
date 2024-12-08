`timescale 1ns / 1ps

module ALU_RTL_tb;

    // Inputs
    reg [3:0] A;
    reg [3:0] B;
    reg [1:0] control;

    // Outputs
    wire [3:0] op;
    wire c_out;

    // Instantiate the Unit Under Test (UUT)
    ALU_RTL uut (
        .A(A),
        .B(B),
        .control(control),
        .op(op),
        .c_out(c_out)
    );

    // Testbench logic
    initial begin
        // Initialize inputs
        A = 4'b0;
        B = 4'b0;
        control = 2'b0;

        // Monitor outputs
        $monitor("Time=%0d | A=%b | B=%b | Control=%b | Output=%b | Carry=%b", 
                  $time, A, B, control, op, c_out);

        // Test Addition
        #10 A = 4'b0011; B = 4'b0101; control = 2'b00; // A=3, B=5 -> ADD: 8
        #10 A = 4'b1111; B = 4'b0001; control = 2'b00; // A=-1, B=1 -> ADD: 0 (two's complement)

        // Test Subtraction
        #10 A = 4'b0101; B = 4'b0011; control = 2'b01; // A=5, B=3 -> SUB: 2
        #10 A = 4'b0011; B = 4'b0101; control = 2'b01; // A=3, B=5 -> SUB: -2 (two's complement)

        // Test Multiplication
        #10 A = 2'b01; B = 2'b10; control = 2'b10; // A=3, B=2 -> MUL: 6
        #10 A = 2'b11; B = 2'b10; control = 2'b10; // A=-1, B=-2 -> MUL: 2 (two's complement)

        // Test Division
        #10 A = 4'b0010; B = 4'b1000; control = 2'b11; // A=4, B=2 -> DIV: 2
        #10 A = 4'b0001; B = 4'b0000; control = 2'b11; // A=5, B=0 -> DIV: Error (1111)

        // Add some delay to observe the output
        #20;

        // End simulation
        $stop;
    end

endmodule
