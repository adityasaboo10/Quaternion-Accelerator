module FIFO (
    input clk,
    input reset,
    input write_en,
    input read_en,
    input [15:0] in0, in1, in2, in3,
    input [15:0] in4, in5, in6, in7,
    output reg [15:0] out0, out1, out2, out3,
    output reg [15:0] out4, out5, out6, out7,
    output reg full,
    output reg empty
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
endmodule