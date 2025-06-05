module Multiplier (S, A, B);
    input  [15:0] A;
    input  [15:0] B;
    output [31:0] S;

    wire [15:0] pp [15:0];
    genvar i, j;
    generate
        for (i = 0; i < 16; i = i + 1) begin: row
            for (j = 0; j < 16; j = j + 1) begin: col
                assign pp[i][j] = A[j] & B[i];
            end
        end
    endgenerate

    wire [31:0] partial_sum [0:15];
    wire [31:0] carry_out [0:15];
    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin: adders
            if (k == 0) begin
                assign partial_sum[0] = {16'b0, pp[0]};
                assign carry_out[0] = 32'b0;
            end else begin
                wire [31:0] shifted_pp;
                assign shifted_pp = {pp[k], {k{1'b0}}}; //Left shift
                ripple_carry_adder R (
                    .A(partial_sum[k-1]),
                    .B(shifted_pp),
                    .Cin(1'b0),
                    .Sum(partial_sum[k]),
                    .Cout(carry_out[k])
                );
            end
        end
    endgenerate

    assign S = partial_sum[15];
endmodule