/*
 Takes in main period signal from channel and outputs a square wave from it.
*/
module sq_wave_generator(/*AUTOARG*/
   // Outputs
   square,
   // Inputs
   period
   );
   input  wire  [ 7:0] period;
   output logic [10:0] square;

   always_comb square = (period[7]) ? 11'b1 : 11'b0;
endmodule
