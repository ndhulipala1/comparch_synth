/*
 Takes in main period signal from channel and outputs a triangle wave from it.
*/
module tri_wave_generator(/*AUTOARG*/
   // Outputs
   triangle,
   // Inputs
   period
   );
   input  wire  [ 7:0] period;
   output logic [10:0] triangle;

   always_comb begin
      triangle = period[7] ? {~period[6:0], ~{4{period[0]}}}
                           : { period[6:0],  {4{period[0]}}};
   end
endmodule
