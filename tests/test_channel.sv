`timescale 1ns / 1ps

module test_channel;
   // Channel params
   parameter M = 6;  // Period size in bits
   parameter N = 10; // Waveform size in bits
   parameter C = 14; // Pitch in bits

   // Outputs
   wire [N-1:0] out;

   // Inputs
   logic clk, ena, rst;
   logic [C-1:0] pitch;
   logic [1:0]  waveform;

   // Base it off the real world version
   parameter CLOCK_FREQ = 12_000_000; // 12MHz
   parameter NOTE_CYCLES = 100_000; // Cycles to hold each note in test

   // Based on the formula for the synth pitch input
   // pitch(freq) = (clk/(2*(2^M)*freq)) - 1
   parameter A440 = 212;
   parameter A880 = 105;

   channel #(.M(M), .N(N), .C(C))
   UUT(/*AUTOINST*/
       // Outputs
       .out                             (out[N-1:0]),
       // Inputs
       .pitch                           (pitch[C-1:0]),
       .waveform                        (waveform[1:0]),
       .clk                             (clk),
       .ena                             (ena),
       .rst                             (rst));

   always #5 clk = ~clk;

   initial begin
      $dumpfile("channel.fst");
      $dumpvars(0, UUT);

      // Reset the clock divider
      clk = 0;
      ena = 0;
      rst = 1;
      waveform = 0;
      pitch = 100; // Should be irrelevant during reset but set it to something
      repeat (2) @(negedge clk);

      // Leaving the code here but noting that this is now irrelevant after
      // refactoring to use the monostable on the divided clock instead of the
      // state machine for resetting divided clock logic

      // Reset signals that depend on divided clock
      rst = 0;
      pitch = 100; // The input pitch should be ignored during a clock divide reset
      repeat (4) @(negedge clk);

      // Test with A440Hz
      rst = 0;
      ena = 1;
      pitch = A440;

      // square
      waveform = 0;
      repeat (NOTE_CYCLES) @(posedge clk);
      // triangle
      waveform = 1;
      repeat (NOTE_CYCLES) @(posedge clk);

      // Right now 2 is undefined

      // saw
      waveform = 3;
      repeat (NOTE_CYCLES) @(posedge clk);

      // Test with A880
      pitch = A880;

      // square
      waveform = 0;
      repeat (NOTE_CYCLES) @(posedge clk);
      // triangle
      waveform = 1;
      repeat (NOTE_CYCLES) @(posedge clk);

      // Right now 2 is undefined

      // saw
      waveform = 3;
      repeat (NOTE_CYCLES) @(posedge clk);

      $finish;
   end

endmodule
