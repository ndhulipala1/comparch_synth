/*
  Outputs a pulse generator with a period of "ticks".
  out should go high for one cycle ever "ticks" clocks.
*/
module pulse_generator(clk, rst, ena, ticks, out);

parameter N = 8;
input wire clk, rst, ena;
input wire [N-1:0] ticks;
output logic out;


logic local_reset;
always_comb out = counter == ticks;

logic [N-1:0] counter;
always_ff @(posedge clk) begin
  if(rst | out) begin
    counter <= 0;
  end else if(ena) begin
    counter <= counter + 1;
  end
  // this always exists:
  // else counter <= counter;
end

endmodule
