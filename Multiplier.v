`timescale 1ns / 1ps
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