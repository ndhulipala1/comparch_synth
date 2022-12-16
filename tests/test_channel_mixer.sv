`timescale 1ns / 1ps

module test_channel_mixer;
   // Channel params
   parameter NUM = 4;
   parameter M = 6;
   parameter C = 14;

   // Base it off the real world version
   parameter CLOCK_FREQ = 12_000_000; // 12MHz
   parameter NOTE_CYCLES = 100_000; // Cycles to hold each note in test

   // Based on the formula for the synth pitch input
   // pitch(freq) = (clk/(2*(2^M)*freq)) - 1
   parameter A4  = 212;
   parameter Cs5 = 168;
   parameter E5  = 141;
   parameter A5  = 106;

   // Outputs
   wire  [11:0] audio;
   // Inputs
   logic [(NUM*C)-1:0] pitches;
   logic [    NUM-1:0] channel_ena;
   logic [(NUM*2)-1:0] waveforms;
   logic               clk, rst;


   channel_mixer #(.NUM(NUM), .M(M), .C(C))
   UUT(/*AUTOINST*/
       // Outputs
       .audio                           (audio[11:0] ),
       // Inputs
       .pitches                         (pitches[(NUM*C)-1:0]),
       .channel_ena                     (channel_ena[NUM-1:0]),
       .waveforms                       (waveforms[(NUM*2)-1:0]),
       .clk                             (clk),
       .rst                             (rst));

   always #5 clk = ~clk;

   initial begin
      $dumpfile("channel_mixer.fst");
      $dumpvars(0, UUT);

      // Reset
      clk = 0;
      rst = 1;

      channel_ena = 0; // Turn off all channels
      waveforms   = 0; // Set all waves to square
      pitches     = 0; // Set all pitch dividers to 0 (the waveform would
                       // actually be above human hearing)
      repeat (4) @(negedge clk);

      // Set CH0 to A4
      rst = 0;
      channel_ena[0] = 1;
      pitches[C-1:0] = A4;
      waveforms[1:0] = 0; // Square
      repeat (NOTE_CYCLES) @(posedge clk);

      // Set CH1 to Cs5
      channel_ena[1] = 1;
      pitches[(C*(1+1))-1:(C*1)] = Cs5;
      waveforms[3:2] = 0; // Square
      repeat (NOTE_CYCLES) @(posedge clk);

      // Set CH2 to E5
      channel_ena[2] = 1;
      pitches[(C*(2+1))-1:(C*2)] = E5;
      waveforms[5:4] = 0; // Square
      repeat (NOTE_CYCLES) @(posedge clk);

      // Set CH3 to A5
      channel_ena[3] = 1;
      pitches[(C*(3+1))-1:(C*3)] = E5;
      waveforms[7:6] = 0; // Square
      repeat (NOTE_CYCLES) @(posedge clk);

      // Set all channels to a different waveform
      waveforms = 8'b11_10_01_00;
      // CH0: square
      // CH1: triangle
      // CH2: saw
      // CH3: undefined (square)
      repeat (NOTE_CYCLES) @(posedge clk);

      $finish;
   end

endmodule
