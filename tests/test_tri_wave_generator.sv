`timescale 1ns / 1ps

module test_tri_wave_generator;
   parameter WAVE_CYCLES = 256;

   wire [10:0] triangle;
   logic [7:0] period;

   tri_wave_generator UUT(/*AUTOINST*/
                          // Outputs
                          .triangle             (triangle[10:0]),
                          // Inputs
                          .period               (period[7:0]));

   initial begin
      $dumpfile("tri_wave_generator.fst");
      $dumpvars(0, UUT);

      for (int i = 0; i < WAVE_CYCLES*2; i = i + 1) begin // Two cycles of the wave
         period = i[7:0];
         #1;
      end
   end
endmodule
