`default_nettype none
`timescale 1ns / 100ps

module channel (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, ena, pitch, waveform
   );
   // These parameters are used as constants, not to parameterize
   // instantiations
   parameter max_freq = 20000;
   input wire [$clog2(20000)-1:0] pitch;
   input wire                     clk, ena;
   input wire [1:0]               waveform;
   output logic [10:0]            out; // 11 bit output as DAC is 12 bits.

   // Signals for each waveform
   wire [10:0] triangle, sine, sawtooth;

   // Square Wave
   logic [10:0] square;
   wire         square_one_bit;
   always_comb square = {11{square_one_bit}};
   sq_wave_generator #(.N($clog2(max_freq)))
   SQ_GEN(.clk(clk),
          .rst(1'b0),
          .ena(ena),
          .pitch_ticks(pitch),
          .out(square_one_bit));

   // Select which waveform signal to use
   always_comb begin
      if (ena) begin
         out = 0;
      end
      else begin
         case (waveform)
           2'b00 : out = square;
           2'b01 : out = triangle;
           2'b10 : out = sine;
           2'b11 : out = sawtooth;
         endcase
      end
   end
endmodule
