`timescale 1ns/1ps
`default_nettype none
/*
    a 1 bit adder that we can daisy chain for
    ripple carry adders
*/

module adder_1(a, b, c_in, sum, c_out);

input wire a, b, c_in;
output logic sum, c_out;

always_comb begin : adder_gates
    a_and_b = a & b;
    half_sum = a ^ b;
    c_out = a_and_b | (half_sum & c_in);
    sum = half_sum ^ c_in;
end


endmodule