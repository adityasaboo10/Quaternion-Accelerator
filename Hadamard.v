`timescale 1ns / 1ps
module Hadamard(
    input signed [15:0] a0, a1, a2, a3,
    output signed [15:0] g0, g1, g2, g3
    );
    
    wire signed [15:0] i0, i1, i2, i3, i4, i5, i6, i7;
    
    Adder A1 ( .p(a0), .q(a1), .cin(1'd0), .cout(), .sum(i0));
    Adder A2 ( .p(i0), .q(a2), .cin(1'd0), .cout(), .sum(i1));
    Adder A3 ( .p(i1), .q(a3), .cin(1'd0), .cout(), .sum(g0));
    
   Adder S1 ( .p(a0), .q(a1), .cin(1'd1), .cout(), .sum(i2));
    Adder A4 ( .p(i2), .q(a2), .cin(1'd0), .cout(), .sum(i3));
    Adder S2 ( .p(i3), .q(a3), .cin(1'd1), .cout(), .sum(g1));

    Adder A5 ( .p(a0), .q(a1), .cin(1'd0), .cout(), .sum(i4));
    Adder S3 ( .p(i4), .q(a2), .cin(1'd1), .cout(), .sum(i5));
    Adder S4 ( .p(i5), .q(a3), .cin(1'd1), .cout(), .sum(g2));
    
    Adder S5 ( .p(a0), .q(a1), .cin(1'd1), .cout(), .sum(i6));
    Adder S6 ( .p(i6), .q(a2), .cin(1'd1), .cout(), .sum(i7));
    Adder A6 ( .p(i7), .q(a3), .cin(1'd0), .cout(), .sum(g3));
endmodule 