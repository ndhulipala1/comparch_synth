`default_nettype none
`timescale 1ns/10ps

module wave_adder(clk, ena, rst, channel1, channel2, out);

// Module I/O and parameters
input wire clk, rst, ena;
input wire [10:0] channel1, channel2;
output logic [11:0] out;

always_comb out = {1'b0, channel1} + {1'b0, channel2};

endmodule