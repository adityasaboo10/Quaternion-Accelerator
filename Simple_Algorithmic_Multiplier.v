`timescale 1ns / 1ps
module Algorithmic_Multiplier(
    input signed [15:0] b0, b1, b2, b3,
    input signed [15:0] x0, x1, x2, x3,
    output signed [15:0] y0, y1, y2, y3
    );
    
    wire signed [15:0] s0, s1, s2, s3;
    wire signed [15:0] s4, s5, s6, s7;
    wire signed [15:0] w0, w1, w2, w3;
    wire signed [15:0] z0, z1, z2, z3;
    wire signed [15:0] m0, m1, m2, m3, m4, m5, m6, m7;
    wire signed [15:0] n0, n1, n2, n3;
    
    Hadamard H1( .a0(x0), .a1(x1), .a2(x2), .a3(x3),
                       .g0(w0), .g1(w1), .g2(w2), .g3(w3)
                      );   
                
    Hadamard H2( .a0(b0), .a1(b1), .a2(b2), .a3(b3),
                       .g0(s0), .g1(s1), .g2(s2), .g3(s3)
                      ); 
                
   assign s4 = b1 <<< 1;
   assign s5 = b3 <<< 1;
   assign s6 = b2 <<< 1;
   assign s7 = b0 <<< 1;

    
    Multiplication M0 ( .a(s0), .b(w0),.out(m0));
    Multiplication M1 ( .a(s1), .b(w1),.out(m1));
    Multiplication M2 ( .a(s2), .b(w2),.out(m2));
    Multiplication M3 ( .a(s3), .b(w3),.out(m3));
    Multiplication M4 ( .a(s6), .b(x1),.out(m4));
    Multiplication M5 ( .a(s4), .b(x3),.out(m5));
    Multiplication M6 ( .a(s5), .b(x2),.out(m6));
    Multiplication M7 ( .a(s7), .b(x0),.out(m7));
    
    Hadamard H3( .a0(m0), .a1(m1), .a2(m2), .a3(m3),
                       .g0(z0), .g1(z1), .g2(z2), .g3(z3)
                      );
   assign n0 = z0 >>> 2;
   assign n1 = z1 >>> 2;
   assign n2 = z2 >>> 2;
   assign n3 = z3 >>> 2;

    
    Adder S0 ( .p(m7), .q(n0), .cin(1'd1), .sum(y0), .cout());
    Adder S1 ( .p(n3), .q(m4), .cin(1'd1), .sum(y3), .cout());
    Adder S2 ( .p(n2), .q(m5), .cin(1'd1), .sum(y2), .cout());
    Adder S4 ( .p(n1), .q(m6), .cin(1'd1), .sum(y1), .cout());
    
endmodule
