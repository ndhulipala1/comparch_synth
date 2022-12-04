`default_nettype none
`timescale 1ns / 100ps

/*
 Channel for synthesizer.
 Output frequency is clk/(2*256*(pitch+1)), where clk is 12MHz.
*/

module channel (/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   clk, ena, pitch, rst, waveform
   );
   output logic [10:0] out; // 11 bit output as DAC is 12 bits.

   input wire [11:0] pitch;
   input wire [1:0]  waveform;
   input wire        clk, rst, ena;

   // Internal counters
   logic [7:0] period; // 8bit counter to send to wave generators, the period
                       // of the wave goes from 0 to 255

   wire clk_div;
   clock_divider #(.N(12)) CLK_DIVIDER (// Outputs
                                        .clk_divided (clk_div),
                                        // Inputs
                                        .clk         (clk),
                                        .rst         (rst),
                                        .divide      (pitch));
   always_ff @(posedge clk_div) begin
      if (rst) begin
         period <= 0;
      end
      else begin
         period <= period + 1;
      end
   end

   // Signals for each waveform
   wire [10:0] square, triangle, sine, sawtooth;

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
