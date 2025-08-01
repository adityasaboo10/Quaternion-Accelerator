`timescale 1ns / 1ps
module SimpleQuaternion_mul(
    input signed [15:0] x0, x1, x2, x3,
    input signed [15:0] b0, b1, b2, b3,
    output signed [15:0] y0, y1, y2, y3
);
    // Intermediate products
    wire signed [15:0] m0, m1, m2, m3;
    wire signed [15:0] m4, m5, m6, m7;
    wire signed [15:0] m8, m9, m10, m11;
    wire signed [15:0] m12, m13, m14, m15;

    // y0 = x0*b0 - x1*b1 - x2*b2 - x3*b3
    Multiplication M0 (.a(x0), .b(b0), .out(m0));
    Multiplication M1 (.a(x1), .b(b1), .out(m1));
    Multiplication M2 (.a(x2), .b(b2), .out(m2));
    Multiplication M3 (.a(x3), .b(b3), .out(m3));
    wire signed [15:0] t0, t1;
    Adder S0 (.p(m0), .q(m1), .cin(1'b1), .sum(t0));   // m0 - m1
    Adder S1 (.p(t0), .q(m2), .cin(1'b1), .sum(t1));   // - m2
    Adder S2 (.p(t1), .q(m3), .cin(1'b1), .sum(y0));   // - m3

    // y1 = x0*b1 + x1*b0 + x2*b3 - x3*b2
    Multiplication M4 (.a(x0), .b(b1), .out(m4));
    Multiplication M5 (.a(x1), .b(b0), .out(m5));
    Multiplication M6 (.a(x2), .b(b3), .out(m6));
    Multiplication M7 (.a(x3), .b(b2), .out(m7));
    wire signed [15:0] t2, t3;
    Adder A0 (.p(m4), .q(m5), .cin(1'b0), .sum(t2));   // +
    Adder A1 (.p(t2), .q(m6), .cin(1'b0), .sum(t3));   // +
    Adder S3 (.p(t3), .q(m7), .cin(1'b1), .sum(y1));   // - m7

    // y2 = x0*b2 - x1*b3 + x2*b0 + x3*b1
    Multiplication M8  (.a(x0), .b(b2), .out(m8));
    Multiplication M9  (.a(x1), .b(b3), .out(m9));
    Multiplication M10 (.a(x2), .b(b0), .out(m10));
    Multiplication M11 (.a(x3), .b(b1), .out(m11));
    wire signed [15:0] t4, t5;
    Adder S4 (.p(m8), .q(m9), .cin(1'b1), .sum(t4));   // - m9
    Adder A2 (.p(t4), .q(m10), .cin(1'b0), .sum(t5));  // +
    Adder A3 (.p(t5), .q(m11), .cin(1'b0), .sum(y2));  // +

    // y3 = x0*b3 + x1*b2 - x2*b1 + x3*b0
    Multiplication M12 (.a(x0), .b(b3), .out(m12));
    Multiplication M13 (.a(x1), .b(b2), .out(m13));
    Multiplication M14 (.a(x2), .b(b1), .out(m14));
    Multiplication M15 (.a(x3), .b(b0), .out(m15));
    wire signed [15:0] t6, t7;
    Adder A4 (.p(m12), .q(m13), .cin(1'b0), .sum(t6)); // +
    Adder S5 (.p(t6), .q(m14), .cin(1'b1), .sum(t7));  // - m14
    Adder A5 (.p(t7), .q(m15), .cin(1'b0), .sum(y3));  // +

endmodule
