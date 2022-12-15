`default_nettype none
`timescale 1ns / 100ps

/*
 Channel for synthesizer.

 Output frequency is clk/(2*256*(pitch+1)), where clk is 12MHz.

 To find correct `pitch` parameter for frequency:
    pitch(freq) = (clk/(2*256*freq)) - 1
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
   input wire        clk, ena, rst;

   // Internal counters
   logic [7:0] period; // 8bit counter to send to wave generators, the period
                       // of the wave goes from 0 to 255

   wire         clk_div;
   clock_divider #(.N(12)) CLK_DIVIDER (// Outputs
                                        .clk_divided (clk_div),
                                        // Inputs
                                        .clk         (clk),
                                        .rst         (rst),
                                        .divide      (pitch));

   wire clk_div_pulse; // Feed divided clock into monostable
   monostable CLK_DIVIDER_MONOSTABLE (// Outputs
                                      .out     (clk_div_pulse),
                                      // Inputs
                                      .clk     (clk),
                                      .rst     (rst),
                                      .button  (clk_div));

   always_ff @(posedge clk) begin
      if (rst) begin
         period <= 0;
      end
      else begin
         period <= clk_div_pulse ? period + 1 : period;
      end
   end

   // Signals for each waveform
   wire [10:0] square, triangle, sine, saw;

   sq_wave_generator SQ_WAVE (/*AUTOINST*/
                              // Outputs
                              .square           (square[10:0]),
                              // Inputs
                              .period           (period[7:0]));
   tri_wave_generator TRI_WAVE (/*AUTOINST*/
                                // Outputs
                                .triangle       (triangle[10:0]),
                                // Inputs
                                .period         (period[7:0]));
   sine_wave_generator SINE_WAVE (/*AUTOINST*/
                                  // Outputs
                                  .sine                 (sine[10:0]),
                                  // Inputs
                                  .period               (period[7:0]));
   saw_wave_generator SAW_WAVE (/*AUTOINST*/
                                // Outputs
                                .saw            (saw[10:0]),
                                // Inputs
                                .period         (period[7:0]));

   // Select which waveform signal to use
   always_comb begin
      if (~ena) begin
         out = 0;
      end
      else begin
         case (waveform)
           2'b00 : out = square;
           2'b01 : out = triangle;
           2'b10 : out = sine;
           2'b11 : out = saw;
         endcase
      end
   end
endmodule
