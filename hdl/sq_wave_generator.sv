/*
 Takes in main period signal from channel and outputs a square wave from it.
*/
module sq_wave_generator(/*AUTOARG*/
   // Outputs
   square,
   // Inputs
   period
   );
   // Number of pins on input
   parameter M = 6;
   // Number of pins on output
   parameter N = 11;

   input  wire  [M-1:0] period;
   output logic [N-1:0] square;

   always_comb square = (period[M-1]) ? -1 : 0;
endmodule
