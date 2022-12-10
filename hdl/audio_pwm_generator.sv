`timescale 1ns/1ps
`default_nettype none

/*
 Module to pulse-width modulate an audio signal.
 Feed output from this module to Digilent PmodAMP2 amplifier.

 Follows this blog post to generate a superior PWM signal (effectively PDM)
 https://zipcpu.com/dsp/2017/09/04/pwm-reinvention.html

 I would not have come up with the idea to reverse the bits of the counter
 myself.
*/

module audio_pwm_generator(/*AUTOARG*/
   // Outputs
   pwm_out,
   // Inputs
   audio, clk, ena, rst
   );

   parameter RELOAD = 272; // Clock cycles to module a sample before changing
                           // sample. Works out to be about 44.1kHz sampling
                           // rate at 12 MHz clock

   output logic pwm_out; // PWM output of combined audio signals. Feed into
                         // Digilent PmodAMP2 AIN pin.

   input wire [11:0] audio; // Waveform inputs
   input wire        clk,   // Standard inputs
                     ena,
                     rst;

   // Logic to take audio samples
   logic [              11:0] sample;       // Audio sample
   logic [$clog2(RELOAD)-1:0] sample_timer; // Counter to take new sample
   always_ff @(posedge clk) begin
      if (rst) begin
         sample       <= audio;
         sample_timer <= RELOAD;
      end
      if (ena) begin
         if (sample_timer == 0) begin // Retake sample
            sample       <= audio;
            sample_timer <= RELOAD;
         end
         else begin // Only change counter if enabled
            sample_timer <= sample_timer - 1;
         end
      end
   end

   // Logic to modulate signal
   logic [11:0] pwm_counter;
   wire  [11:0] pwm_counter_rev; // Bit reversed pwm counter

   // The effect of reversing the counter is instead of the least significant
   // bit changing every clock, the most significant bit does. Thus, when you
   // do the less than comparison, it modulates more frequently. The ultimate
   // number of high and low pulses per sample stays the same, they are just
   // spaced differently, more changes at high amplitudes and less changes at
   // low amplitudes.

   generate // Reverse the counter.
      genvar i;
      for (i=0; i<12; i++) begin
         assign pwm_counter_rev[i] = pwm_counter[11-i];
      end
   endgenerate
   always_ff @(posedge clk) begin // Update the pwm counter
      if (rst) begin
         pwm_counter <= 0;
      end
      if (ena) begin
         pwm_counter <= pwm_counter + 1;
      end
   end
   // Modulate sample based off reversed counter
   always_ff @(posedge clk) begin
      if (ena) begin
         pwm_out <= (sample >= pwm_counter_rev);
      end
   end

endmodule
