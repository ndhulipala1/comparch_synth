/*
 Takes in main period signal from channel and outputs a sawtooth wave from it.
*/
module saw_wave_generator(/*AUTOARG*/
   // Outputs
   saw,
   // Inputs
   period
   );
   // Number of bits on the input
   parameter M = 6;
   // Number of bits on the output
   // Must be greater than size of input
   parameter N = 11;
   
   input  wire  [M-1:0] period;
   output logic [N-1:0] saw;

   always_comb saw = {period, {(N-M){period[0]}}};

endmodule
