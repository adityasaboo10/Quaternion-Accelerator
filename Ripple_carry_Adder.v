module ripple_carry_adder(A,B,Cin,Sum,Cout);
    input  [31:0] A;
    input  [31:0] B;
    input Cin;
    output [31:0] Sum;
    output Cout;
    wire [31:0] c;
    full_adder fa0 (A[0],B[0],Cin,Sum[0],c[0]);
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin: adders
            full_adder fa (A[i], B[i], c[i-1], Sum[i], c[i]);
        end
    endgenerate
    assign Cout = c[31];
endmodule
