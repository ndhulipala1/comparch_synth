`timescale 1ns / 1ps

module test_wave_adder;
   // Parameters for wave adder
   parameter NUM = 4;
   parameter N   = 4; // 4 4-bit channels

   // Outputs
   wire [11:0] audio;

   // Inputs
   logic [NUM*N-1:0] channels;

   wave_adder #(.NUM(NUM), .N(N))
   UUT(/*AUTOINST*/
       // Outputs
       .audio                           (audio[11:0]),
       // Inputs
       .channels                        (channels[(N*NUM)-1:0]));


   initial begin
      $dumpfile("wave_adder.fst");
      $dumpvars(0, UUT);

      // Set all channels to 0, output should be 0
      channels = 0;
      #20;

      // Output should be 1
      channels[3:0] = 1;
      #20;

      // Output should be 3
      channels[7:4] = 2;
      #20;

      // Output should be 7
      channels[11:8] = 4;
      #20;

      // Output should be 15
      channels[15:12] = 8;
      #20

      $finish;
   end

endmodule
