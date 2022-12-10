`default_nettype none
`timescale 1ns / 1ps

module main(/*AUTOARG*/
   // Outputs
   pwm_out,
   // Inputs
   buttons, clk, rst
   );
   input wire clk, rst;
   
   input  wire [1:0] buttons;
   output wire       pwm_out; // Driven by module

   // Map buttons to channel enable signals
   logic channel1_ena, channel2_ena;
   always_comb begin
      channel1_ena = buttons[0];
      channel2_ena = buttons[1];
   end

   // For now, tie each button to a specific pitch. Analog input can be handled
   // later. Also ties them to sine waves and enabled.
   logic [11:0] channel1_pitch, channel2_pitch;
   logic [ 1:0] waveform1, waveform2;
   always_comb begin
      // A 5th (or the best approximation of one we can make)
      // pitch1 = 52; // A4, 440Hz
      // pitch2 = 35; // E5, 659Hz
      
      // Rufford Park Poachers Simulator Rehearsal B to F
      channel1_pitch = 178; // C3, Neel Trombone
      channel2_pitch = 44;  // C5, Devlin Flute

      // Waveforms
      waveform1 = 2'b10;
      waveform2 = 2'b10;
   end // always_comb

   wire [10:0] channel1_out, channel2_out;

   // Instantiate 2 channels
   channel CHANNEL1 (// Outputs
                     .out      (channel1_out),
                     // Inputs
                     .pitch    (channel1_pitch),
                     .waveform (waveform1),
                     .clk      (clk),
                     .ena      (channel1_ena),
                     .rst      (rst));

   channel CHANNEL2 (// Outputs
                     .out      (channel2_out),
                     // Inputs
                     .pitch    (channel2_pitch),
                     .waveform (waveform2),
                     .clk      (clk),
                     .ena      (channel2_ena),
                     .rst      (rst));

   // Sum channels together
   wire [11:0] audio;
   wave_adder WAVE_ADDER (// Outputs
                          .out      (audio),
                          // Inputs
                          .channel1 (channel1_out),
                          .channel2 (channel2_out));

   // PWM Modulate audio signal
   audio_pwm_generator PWM_GENERATOR (.ena              (1'b1),
                                      /*AUTOINST*/
                                      // Outputs
                                      .pwm_out          (pwm_out),
                                      // Inputs
                                      .audio            (audio[11:0]),
                                      .clk              (clk),
                                      .rst              (rst));
   
endmodule
