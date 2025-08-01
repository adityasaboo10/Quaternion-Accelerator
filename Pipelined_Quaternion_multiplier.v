module Algorithmic_Multiplier(
    input signed [15:0] b0, b1, b2, b3,
    input signed [15:0] x0, x1, x2, x3,
    input clk,
    output signed [15:0] y0, y1, y2, y3
);

    wire signed [15:0] s0, s1, s2, s3;
    wire signed [15:0] s4, s5, s6, s7;
    wire signed [15:0] w0, w1, w2, w3;
    wire signed [15:0] z0, z1, z2, z3;
    wire signed [15:0] m0, m1, m2, m3, m4, m5, m6, m7;
    wire signed [15:0] n0, n1, n2, n3;

    assign s4 = b1 <<< 1;
    assign s5 = b3 <<< 1;
    assign s6 = b2 <<< 1;
    assign s7 = b0 <<< 1;

    reg signed [15:0] s4_latch, s5_latch, s6_latch, s7_latch;
    reg signed [15:0] b0_latch, b1_latch, b2_latch, b3_latch;
    reg signed [15:0] x0_latch, x1_latch, x2_latch, x3_latch;

    always @(posedge clk) begin
        s4_latch <= s4;
        s5_latch <= s5;
        s6_latch <= s6;
        s7_latch <= s7;
        b0_latch <= b0;
        b1_latch <= b1;
        b2_latch <= b2;
        b3_latch <= b3;
        x0_latch <= x0;
        x1_latch <= x1;
        x2_latch <= x2;
        x3_latch <= x3;
    end

    Hadamard H1(
        .a0(x0_latch), .a1(x1_latch), .a2(x2_latch), .a3(x3_latch),
        .g0(w0), .g1(w1), .g2(w2), .g3(w3)
    );

    Hadamard H2(
        .a0(b0_latch), .a1(b1_latch), .a2(b2_latch), .a3(b3_latch),
        .g0(s0), .g1(s1), .g2(s2), .g3(s3)
    );

    reg signed [15:0] w0_latch, w1_latch, w2_latch, w3_latch;
    reg signed [15:0] s0_latch, s1_latch, s2_latch, s3_latch;
    reg signed [15:0] s4_latch1, s5_latch1, s6_latch1, s7_latch1;
    reg signed [15:0] x0_latch1, x1_latch1, x2_latch1, x3_latch1;

    always @(posedge clk) begin
        w0_latch <= w0;
        w1_latch <= w1;
        w2_latch <= w2;
        w3_latch <= w3;

        s0_latch <= s0;
        s1_latch <= s1;
        s2_latch <= s2;
        s3_latch <= s3;

        s4_latch1 <= s4_latch;
        s5_latch1 <= s5_latch;
        s6_latch1 <= s6_latch;
        s7_latch1 <= s7_latch;

        x0_latch1 <= x0_latch;
        x1_latch1 <= x1_latch;
        x2_latch1 <= x2_latch;
        x3_latch1 <= x3_latch;
    end

    Multiplication M0 (.a(s0_latch), .b(w0_latch), .out(m0));
    Multiplication M1 (.a(s1_latch), .b(w1_latch), .out(m1));
    Multiplication M2 (.a(s2_latch), .b(w2_latch), .out(m2));
    Multiplication M3 (.a(s3_latch), .b(w3_latch), .out(m3));
    Multiplication M4 (.a(s6_latch1), .b(x1_latch1), .out(m4));
    Multiplication M5 (.a(s4_latch1), .b(x3_latch1), .out(m5));
    Multiplication M6 (.a(s5_latch1), .b(x2_latch1), .out(m6));
    Multiplication M7 (.a(s7_latch1), .b(x0_latch1), .out(m7));
    reg signed [15:0] m0_latch,m1_latch,m2_latch,m3_latch;
    reg signed [15:0] m4_latch,m5_latch,m6_latch,m7_latch;                    
    
    always @(posedge clk) begin
        m0_latch <= m0;
        m1_latch <= m1;
        m2_latch <= m2;
        m3_latch <= m3;
        m4_latch <= m4;
        m5_latch <= m5;
        m6_latch <= m6;
        m7_latch <= m7;
    end


    Hadamard H3(
        .a0(m0_latch), .a1(m1_latch), .a2(m2_latch), .a3(m3_latch),
        .g0(z0), .g1(z1), .g2(z2), .g3(z3)
    );

    assign n0 = z0 >>> 2;
    assign n1 = z1 >>> 2;
    assign n2 = z2 >>> 2;
    assign n3 = z3 >>> 2;
    reg signed [15:0] n0_latch,n1_latch,n2_latch,n3_latch;
    reg signed [15:0] m4_latch1,m5_latch1,m6_latch1,m7_latch1; 
    always @(posedge clk) begin
        n0_latch<=n0;
        n1_latch<=n1;
        n2_latch<=n2;
        n3_latch<=n3;
        m4_latch1 <= m4_latch;
        m5_latch1 <= m5_latch;
        m6_latch1 <= m6_latch;
        m7_latch1 <= m7_latch;
    
    end

    Adder S0 (.p(m7_latch1), .q(n0_latch), .cin(1'd1), .sum(y0), .cout());
    Adder S1 (.p(n3_latch), .q(m4_latch1), .cin(1'd1), .sum(y3), .cout());
    Adder S2 (.p(n2_latch), .q(m5_latch1), .cin(1'd1), .sum(y2), .cout());
    Adder S3 (.p(n1_latch), .q(m6_latch1), .cin(1'd1), .sum(y1), .cout());

endmodule
