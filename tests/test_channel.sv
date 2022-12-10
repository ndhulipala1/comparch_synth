`timescale 1ns / 1ps

module test_channel;
   // Outputs
   wire [10:0] out;

   // Inputs
   logic clk, ena, rst;
   logic [11:0] pitch;
   logic [1:0]  waveform;

   // Base it off the real world version
   parameter CLOCK_FREQ = 12_000_000; // 12MHz
   parameter NOTE_CYCLES = 100_000; // Cycles to hold each note in test

   // Based on the formula for the synth pitch input
   // pitch(freq) = (clk/(2*256*freq)) - 1
   parameter A440 = 52;
   parameter A880 = 26;

   channel UUT(/*AUTOINST*/
               // Outputs
               .out                     (out[10:0]),
               // Inputs
               .pitch                   (pitch[11:0]),
               .waveform                (waveform[1:0]),
               .clk                     (clk),
               .ena                     (ena),
               .rst                     (rst));

   always #5 clk = ~clk;

   initial begin
      $dumpfile("channel.fst");
      $dumpvars(0, UUT);

      // Reset the clock divider
      clk = 0;
      ena = 0;
      rst = 1;
      waveform = 0;
      pitch = 0;
      repeat (2) @(negedge clk);

      // Reset signals that depend on divided clock
      rst = 0;
      pitch = 0; // Ensure minimum time to reset is taken
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
      // sine
      waveform = 2;
      repeat (NOTE_CYCLES) @(posedge clk);
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
      // sine
      waveform = 2;
      repeat (NOTE_CYCLES) @(posedge clk);
      // saw
      waveform = 3;
      repeat (NOTE_CYCLES) @(posedge clk);

      $finish;
   end

endmodule
