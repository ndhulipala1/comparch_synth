`default_nettype none
`timescale 1ns/10ps

/*
 Sum up a channel bus into a 12 bit audio bus.
 NUM must be larger than 1.
*/

// Warning, the following code is hard to read due to attempt to make it
// parameterize.
module wave_adder(/*AUTOARG*/
   // Outputs
   audio,
   // Inputs
   channels
   );

   parameter NUM = 4; // Number of channels to add
   parameter N   = 8; // Bus size of each channel

   // Module I/O and parameters
   input  wire  [(N*NUM)-1:0] channels;
   output logic [11:0] audio;

   // Sum them all up ripple carry style (except it's busses not bits)
   logic [12*NUM-1:0] channels_ext, sums;
   always_comb begin
      // Extend first channel (subsequent ones are in generate statement)
      channels_ext[11:0] = {{12-N{1'b0}}, channels[N-1:0]};
      // Tie first sum to first extended channel
      sums[11:0] = channels_ext [11:0];
      // Last sum is the output
      audio = sums[NUM*12-1:(NUM-1)*12];
   end

   generate
      genvar i;
      for (i=1; i<NUM; i++) begin
         always_comb begin
            // Extend ith channel to 12 bits
            channels_ext[12*(i+1)-1:12*i] = {{(12-N){1'b0}}, channels[N*(i+1)-1:N*i]};
            // Sum i is (i-1)th sum plus ith extended channel
            sums[12*(i+1)-1:12*i] = sums[12*(i)-1:12*(i-1)] + channels_ext[12*(i+1)-1:12*i];
         end
      end
   endgenerate

endmodule
