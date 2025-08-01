`timescale 1ns / 1ps
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