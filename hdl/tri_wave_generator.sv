/*
 Takes in main period signal from channel and outputs a triangle wave from it.
*/
module tri_wave_generator(/*AUTOARG*/
   // Outputs
   triangle,
   // Inputs
   period
   );
   // Number of bits on the input
   parameter M = 6;
   // Number of bits on the output
   parameter N = 11;
   input  wire  [M-1:0] period;
   output logic [N-1:0] triangle;

   always_comb begin
      triangle = period[M-1] ? {~period[M-2:0], ~{(N-M+1){period[0]}}}
                             : { period[M-2:0],  {(N-M+1){period[0]}}};
   end
endmodule
