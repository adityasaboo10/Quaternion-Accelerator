`timescale 1ns / 1ps
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
