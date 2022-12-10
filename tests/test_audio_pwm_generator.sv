`timescale 1ns / 1ps

module test_audio_pwm_generator;
   // Outputs
   wire pwm_out;

   // Inputs
   logic [11:0] audio;
   logic        clk, ena, rst;

   // Base it off the real world version
   parameter CLOCK_FREQ = 12_000_000; // 12MHz

   audio_pwm_generator UUT(/*AUTOINST*/
                           // Outputs
                           .pwm_out             (pwm_out),
                           // Inputs
                           .audio               (audio[11:0]),
                           .clk                 (clk),
                           .ena                 (ena),
                           .rst                 (rst));

   // Instantiate a sine wave generator to modulate
   logic [ 7:0] period;
   logic [10:0] sine;
   sine_wave_generator SINE1 (.sine   (sine),
                              .period (period));
   always_comb audio = {sine, 1'b0};

   always #2 clk = ~clk;

   initial begin
      $dumpfile("audio_pwm_generator.fst");
      $dumpvars(0, UUT);

      // Reset
      period = 0;
      clk = 0;
      ena = 0;
      rst = 1;
      repeat (2) @(negedge clk);

      // Test
      clk = 0;
      ena = 1;
      rst = 0;
      for (int i = 0; i < 10000; i = i + 1) begin
         clk    = i[0];    // Pretend this is 12MHz
         period = i[12:5]; // Pretend this is 2930Hz (closest pitch is F#7)
         #2;
      end
      $finish;
   end

endmodule
