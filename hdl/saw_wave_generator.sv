/*
 Takes in main period signal from channel and outputs a sawtooth wave from it.
*/
module saw_wave_generator(/*AUTOARG*/
   // Outputs
   saw,
   // Inputs
   period
   );
   input  wire  [ 7:0] period;
   output logic [10:0] saw;

   always_comb saw = {period, {3{period[0]}}};

endmodule
