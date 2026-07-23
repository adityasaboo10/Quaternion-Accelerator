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
