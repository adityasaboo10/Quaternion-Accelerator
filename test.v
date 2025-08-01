module data_path (
    input clk,
    input sclk,
    input rst,
    input mosi,
    input cs,
    output [15:0] K0, K1, K2, K3
);

    wire [15:0] q0, q1, q2, q3;
    wire [15:0] q4, q5, q6, q7;
    wire [15:0] x0, x1, x2, x3;
    wire [15:0] b0, b1, b2, b3;
    reg [15:0] t0, t1, t2, t3;

    wire [15:0] j0, j1, j2, j3;  
    wire [15:0] m0, m1, m2, m3;

    wire read_en, write_en;
    wire full, empty;
    wire data_ready;

    spi_slave S1 (
        .sclk(sclk), .rst(rst), .mosi(mosi), .cs(cs),
        .q0(q0), .q1(q1), .q2(q2), .q3(q3),
        .data_ready(data_ready)
    );

    control C1 (
        .clk(clk), .rst(rst),
        .data_ready(data_ready),
        .t0(t0), .t1(t1), .t2(t2), .t3(t3),
        .read_en(read_en), .write_en(write_en),
        .full(full), .empty(empty),
        .out0(q4), .out1(q5), .out2(q6), .out3(q7)
    );

    FIFO1 F1 (
        .clk(clk), .reset(rst),
        .write_en(write_en), .read_en(read_en),
        .in0(q0), .in1(q1), .in2(q2), .in3(q3),
        .in4(q4), .in5(q5), .in6(q6), .in7(q7),
        .out0(x0), .out1(x1), .out2(x2), .out3(x3),
        .out4(b0), .out5(b1), .out6(b2), .out7(b3),
        .full(full), .empty(empty)
    );

    SimpleQuaternion_mul M (
        .x0(x0), .x1(x1), .x2(x2), .x3(x3),
        .b0(b0), .b1(b1), .b2(b2), .b3(b3),
        .y0(j0), .y1(j1), .y2(j2), .y3(j3),
        .clk(clk)
    );
    
    FIFO2 F2 ( 
        .clk(clk), .reset(rst),
        .write_en(write_en), .read_en(read_en),
        .in0(j0), .in1(j1), .in2(j2), .in3(j3),
        .out0(m0), .out1(m1), .out2(m2), .out3(m3),
        .full(full), .empty(empty)
    );

    assign K0 = m0;
    assign K1 = m1;
    assign K2 = m2;
    assign K3 = m3;
    
    always @(data_ready) begin
            if (data_ready) begin
                t0 = j0;
                t1 = j1;
                t2 = j2;
                t3 = j3;
            end else begin
                t0 = b0;
                t1 = b1;
                t2 = b2;
                t3 = b3;
            end
        end
    

endmodule



module control (
    input clk, rst,
    input data_ready,
    input [15:0] t0, t1, t2, t3,
    input full, empty,
    output reg read_en, write_en,
    output reg domul,
    output reg [15:0] out0, out1, out2, out3
);

    // FSM states
    parameter IDLE = 0, WRITE = 1, MULTIPLY = 2;
    reg [1:0] present_state, next_state;

    // Combinational logic: next state & outputs
    always @(*) begin
        // Default outputs
        write_en = 0;
        read_en = 0;
        domul = 0;
        out0 = 1; out1 = 0; out2 = 0; out3 = 0;

        case (present_state)
            IDLE: begin
                next_state = (data_ready && !full) ? WRITE : IDLE;
            end

            WRITE: begin
                write_en = 1;
                out0 = t0; out1 = t1; out2 = t2; out3 = t3;
                next_state = (!empty) ? MULTIPLY : WRITE;
            end

            MULTIPLY: begin
                read_en = 1;
                domul = 1;
                out0 = t0; out1 = t1; out2 = t2; out3 = t3;
                next_state = (data_ready && !full) ? WRITE : IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Sequential logic: update state
    always @(posedge clk or posedge rst) begin
        if (rst)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end

endmodule

module spi_slave(
    input sclk,
    input rst,
    input mosi,
    input cs,
    output reg [15:0] q0, q1, q2, q3,
    output reg data_ready,
    output reg miso
    );
    
    reg [15:0] shift_reg = 16'd0; 
    reg [3:0] bit_count = 4'd0;
    reg [1:0] out_count = 2'd0;
    
    always @(posedge sclk) begin
        if (rst) begin
            q0 <= 16'b0;
            q1 <= 16'b0;
            q2 <= 16'b0;
            q3 <= 16'b0;
            data_ready <= 0;
            shift_reg <= 0;
            bit_count <= 0;
            out_count <= 0;
        end
        else if (~cs) begin
            data_ready <= 0;
            if (bit_count != 4'd15) begin
                shift_reg <= {shift_reg[14:0], mosi};
                bit_count <= bit_count + 1;
            end
            else if (bit_count == 4'd15) begin
                bit_count <= 0;
                case (out_count)
                    2'd0: begin
                            q0 <= {shift_reg[14:0], mosi};                            
                            out_count <= out_count + 1;
                          end
                    2'd1: begin
                            q1 <= {shift_reg[14:0], mosi};                            
                            out_count <= out_count + 1;
                          end
                    2'd2: begin
                            q2 <= {shift_reg[14:0], mosi};                           
                            out_count <= out_count + 1;
                          end
                    2'd3: begin
                            q3 <= {shift_reg[14:0], mosi};                           
                            out_count <= 0;
                            data_ready <= 1;
                          end
                endcase               
            end
        end
    end        
endmodule


module FIFO1 (
    input clk,
    input reset,
    input write_en,
    input read_en,
    input [15:0] in0, in1, in2, in3,
    input [15:0] in4, in5, in6, in7,
    output reg [15:0] out0, out1, out2, out3,
    output reg [15:0] out4, out5, out6, out7,
    output reg full,
    output reg empty,
    output [3:0] fifocount
);
    reg [15:0] mem0[7:0], mem1[7:0], mem2[7:0], mem3[7:0];
    reg [15:0] mem4[7:0], mem5[7:0], mem6[7:0], mem7[7:0];

    reg [2:0] write_ptr = 0, read_ptr = 0;
    reg [3:0] fifo_count = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0; read_ptr <= 0;
            fifo_count <= 0;
            full <= 0; empty <= 1;
            out0 <= 1; out1 <= 0; out2 <= 0; out3 <= 0;
            out4 <= 1; out5 <= 0; out6 <= 0; out7 <= 0;
        end else begin
            if (write_en && !full) begin
                mem0[write_ptr] <= in0;
                mem1[write_ptr] <= in1;
                mem2[write_ptr] <= in2;
                mem3[write_ptr] <= in3;
                mem4[write_ptr] <= in4;
                mem5[write_ptr] <= in5;
                mem6[write_ptr] <= in6;
                mem7[write_ptr] <= in7;
                write_ptr <= (write_ptr == 7) ? 0 : write_ptr + 1;
            end

            if (read_en && !empty) begin
                out0 <= mem0[read_ptr];
                out1 <= mem1[read_ptr];
                out2 <= mem2[read_ptr];
                out3 <= mem3[read_ptr];
                out4 <= mem4[read_ptr];
                out5 <= mem5[read_ptr];
                out6 <= mem6[read_ptr];
                out7 <= mem7[read_ptr];
                read_ptr <= (read_ptr == 7) ? 0 : read_ptr + 1;
            end

            case ({write_en && !full, read_en && !empty})
                2'b10: fifo_count <= fifo_count + 1;
                2'b01: fifo_count <= fifo_count - 1;
                default: fifo_count <= fifo_count;
            endcase

            full <= (fifo_count == 8);
            empty <= (fifo_count == 0);
        end
    end
    assign fifocount=fifo_count;
endmodule

module FIFO2 (
    input clk,
    input reset,
    input write_en,
    input read_en,
    input [15:0] in0, in1, in2, in3,
    output reg [15:0] out0, out1, out2, out3,
    output reg full,
    output reg empty,
    output [3:0] fifocount
);
    reg [15:0] mem0[7:0], mem1[7:0], mem2[7:0], mem3[7:0];

    reg [2:0] write_ptr = 0, read_ptr = 0;
    reg [3:0] fifo_count = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0; read_ptr <= 0;
            fifo_count <= 0;
            full <= 0; empty <= 1;
            out0 <= 1; out1 <= 0; out2 <= 0; out3 <= 0;
        end else begin
            if (write_en && !full) begin
                mem0[write_ptr] <= in0;
                mem1[write_ptr] <= in1;
                mem2[write_ptr] <= in2;
                mem3[write_ptr] <= in3;
                write_ptr <= (write_ptr == 7) ? 0 : write_ptr + 1;
            end

            if (read_en && !empty) begin
                out0 <= mem0[read_ptr];
                out1 <= mem1[read_ptr];
                out2 <= mem2[read_ptr];
                out3 <= mem3[read_ptr];
                read_ptr <= (read_ptr == 7) ? 0 : read_ptr + 1;
            end

            case ({write_en && !full, read_en && !empty})
                2'b10: fifo_count <= fifo_count + 1;
                2'b01: fifo_count <= fifo_count - 1;
                default: fifo_count <= fifo_count;
            endcase

            full <= (fifo_count == 8);
            empty <= (fifo_count == 0);
        end
    end
    assign fifocount=fifo_count;
endmodule

module Adder(
    input signed [15:0] p,
    input signed [15:0] q,
    input signed cin,
    output signed [15:0] sum,
    output signed cout
);
    wire [15:0] t;
    assign t={16{cin}} ^q ;

    wire signed [15:0] carry;

    Full_Adder FA0 (
        .p(p[0]),
        .q(t[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(carry[0])
    );

    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : full_adder_chain
            Full_Adder FA (
                .p(p[i]),
                .q(t[i]),
                .cin(carry[i-1]),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    assign cout = carry[15];

endmodule
module Full_Adder(
    input signed p,
    input signed q,
    input signed cin,
    output signed cout,
    output signed sum
    );
    
    wire signed w1, w2, w3, w4;
    
    xor(w1, p, q);
    xor(sum, w1, cin);
    
    and(w2, p, q);
    and(w3, p, cin);
    and(w4, q, cin);
    or(cout, w2, w3, w4);
endmodule



module Multiplication(
    input signed [15:0] a,
    input signed [15:0] b,
    output reg signed [15:0] out    
);

    reg signed [15:0] accm;
    reg signed [15:0] tempb;
    reg signed [16:0] sum;
    reg signed carry;
    integer i;
    reg [31:0] temmmp;

    always @(*) begin
        accm = 0;
        tempb = b;
        carry = 0;

        for (i = 0; i < 16; i = i + 1) begin
            if (tempb[0] == 0) begin
                tempb = {accm[0], tempb[15:1]};
                accm = {carry, accm[15:1]};
            end
            else begin
                sum = accm + a;
                carry = sum[16];
                accm = sum[15:0];
                tempb = {accm[0], tempb[15:1]};
                accm = {carry, accm[15:1]};
            end
        end

         temmmp= {accm, tempb};
         out=temmmp[15:0];
    end
endmodule
module MultiplicationConditions (
    input signed [15:0] a,
    input signed [15:0] b,
    output signed [15:0] out
    );
    
    wire sign;
    wire [15:0] a_usn, b_usn;
    wire [15:0] out_usn;
    
    assign a_usn = a[15] ? ~(a - 1) : a;
    assign b_usn = b[15] ? ~(b - 1) : b;
    
    Multiplication S1( .a(a_usn), .b(b_usn), .out(out_usn)); 
    xor(sign, a[15], b[15]);
    
    assign out = (sign) ? (~out_usn + 1): out_usn;
  
endmodule
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

MultiplicationConditions M0  (.a(x0), .b(b0), .out(O0));
MultiplicationConditions M1  (.a(x1), .b(b1), .out(O1));
MultiplicationConditions M2  (.a(x2), .b(b2), .out(O2));
MultiplicationConditions M3  (.a(x3), .b(b3), .out(O3));
MultiplicationConditions M4  (.a(x0), .b(b1), .out(O4));
MultiplicationConditions M5  (.a(x1), .b(b0), .out(O5));
MultiplicationConditions M6  (.a(x2), .b(b3), .out(O6));
MultiplicationConditions M7  (.a(x3), .b(b2), .out(O7));
MultiplicationConditions M8  (.a(x0), .b(b2), .out(O8));
MultiplicationConditions M9  (.a(x1), .b(b3), .out(O9));
MultiplicationConditions M10 (.a(x2), .b(b0), .out(O10));
MultiplicationConditions M11 (.a(x3), .b(b1), .out(O11));
MultiplicationConditions M12 (.a(x0), .b(b3), .out(O12));
MultiplicationConditions M13 (.a(x1), .b(b2), .out(O13));
MultiplicationConditions M14 (.a(x2), .b(b1), .out(O14));
MultiplicationConditions M15 (.a(x3), .b(b0), .out(O15));

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
    wire signed [15:0] t0, t1, t2, t3;
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
    wire signed [15:0] t4, t5, t6, t7;
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
    wire signed [15:0] y0_wire, y1_wire, y2_wire, y3_wire;
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