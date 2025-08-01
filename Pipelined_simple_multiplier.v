module SimpleQuaternion_mul(
    input signed [15:0] x0, x1, x2, x3,
    input signed [15:0] b0, b1, b2, b3,
    input clk,
    output reg signed [15:0] y0, y1, y2, y3
   
);

    

// --- Stage 1: Multiplication ---
wire signed [15:0] O0, O1, O2, O3;
wire signed [15:0] O4, O5, O6, O7;
wire signed [15:0] O8, O9, O10, O11;
wire signed [15:0] O12, O13, O14, O15;

Multiplication M0  (.a(x0), .b(b0), .out(O0));
Multiplication M1  (.a(x1), .b(b1), .out(O1));
Multiplication M2  (.a(x2), .b(b2), .out(O2));
Multiplication M3  (.a(x3), .b(b3), .out(O3));
Multiplication M4  (.a(x0), .b(b1), .out(O4));
Multiplication M5  (.a(x1), .b(b0), .out(O5));
Multiplication M6  (.a(x2), .b(b3), .out(O6));
Multiplication M7  (.a(x3), .b(b2), .out(O7));
Multiplication M8  (.a(x0), .b(b2), .out(O8));
Multiplication M9  (.a(x1), .b(b3), .out(O9));
Multiplication M10 (.a(x2), .b(b0), .out(O10));
Multiplication M11 (.a(x3), .b(b1), .out(O11));
Multiplication M12 (.a(x0), .b(b3), .out(O12));
Multiplication M13 (.a(x1), .b(b2), .out(O13));
Multiplication M14 (.a(x2), .b(b1), .out(O14));
Multiplication M15 (.a(x3), .b(b0), .out(O15));

// --- Stage 2: Register all products ---
reg signed [15:0] m0, m1, m2, m3;
reg signed [15:0] m4, m5, m6, m7;
reg signed [15:0] m8, m9, m10, m11;
reg signed [15:0] m12, m13, m14, m15;

always @(posedge clk) begin
    m0  <= O0;   m1  <= O1;   m2  <= O2;   m3  <= O3;
    m4  <= O4;   m5  <= O5;   m6  <= O6;   m7  <= O7;
    m8  <= O8;   m9  <= O9;   m10 <= O10;  m11 <= O11;
    m12 <= O12;  m13 <= O13;  m14 <= O14;  m15 <= O15;
end

// --- Stage 3: Adders for grouped sums ---
wire signed [31:0] t0, t1, t2, t3;
Adder A0 (.p(m1),  .q(m2),   .cin(1'd0), .sum(t0), .cout());
Adder A1 (.p(m4),  .q(m5),   .cin(1'd0), .sum(t1), .cout());
Adder A2 (.p(m8),  .q(m10),  .cin(1'd0), .sum(t2), .cout());
Adder A3 (.p(m12), .q(m13),  .cin(1'd0), .sum(t3), .cout());

reg signed [15:0] T0, T1, T2, T3;
reg signed [15:0] m0_R, m3_R, m6_R, m7_R;
reg signed [15:0] m9_R, m11_R, m14_R, m15_R;

always @(posedge clk) begin
    T0 <= t0;   T1 <= t1;   T2 <= t2;   T3 <= t3;
    m0_R  <= m0;    m3_R  <= m3;    m6_R  <= m6;    m7_R  <= m7;
    m9_R  <= m9;    m11_R <= m11;   m14_R <= m14;   m15_R <= m15;
end

// --- Stage 4: Adders for final pre-subtraction sums ---
wire signed [31:0] t4, t5, t6, t7;
Adder A4 (.p(T0),  .q(m3_R),   .cin(1'd0), .sum(t4), .cout());
Adder A5 (.p(T1),  .q(m6_R),   .cin(1'd0), .sum(t5), .cout());
Adder A6 (.p(T2),  .q(m11_R),  .cin(1'd0), .sum(t6), .cout());
Adder A7 (.p(T3),  .q(m15_R),  .cin(1'd0), .sum(t7), .cout());

reg signed [15:0] T4, T5, T6, T7;
reg signed [15:0] m0_r1, m7_r1, m9_r1, m14_r1;

always @(posedge clk) begin
    T4 <= t4;    T5 <= t5;    T6 <= t6;    T7 <= t7;
    m0_r1  <= m0_R;   m7_r1  <= m7_R;
    m9_r1  <= m9_R;   m14_r1 <= m14_R;
end

// --- Stage 5: Final Subtractions ---
wire signed [31:0] y0_wire, y1_wire, y2_wire, y3_wire;
    Adder S0 (.p(m0_r1),  .q(T4),    .cin(1'd1), .sum(y0_wire), .cout());
   Adder S1 (.p(T5),     .q(m7_r1), .cin(1'd1), .sum(y1_wire), .cout());
   Adder S2 (.p(T6),     .q(m9_r1), .cin(1'd1), .sum(y2_wire), .cout());
   Adder S3 (.p(T7),     .q(m14_r1),.cin(1'd1), .sum(y3_wire), .cout());

always @(posedge clk) begin
    y0 <= y0_wire;
    y1 <= y1_wire;
    y2 <= y2_wire;
    y3 <= y3_wire;
end

endmodule
