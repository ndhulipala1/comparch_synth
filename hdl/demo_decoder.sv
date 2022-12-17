`default_nettype none
`timescale 1ns / 1ps

// Decodes data from block ROM for demo

module demo_decoder(/*AUTOARG*/
   // Outputs
   demo_addr, demo_channel_ena, demo_pitches, demo_waveforms,
   // Inputs
   clk, demo_data, ena, rst
   );

   parameter DEMO_SONG_LENGTH = 128;
   parameter DEMO_CLK_DIVIDE = 100; // For tempo

   // Will break if these are specified
   parameter NUM    = 25; // Number of channels
   parameter C      = 12; // Size of pitch input in bits

   output logic [(NUM*C)-1:0] demo_pitches;
   output logic [    NUM-1:0] demo_channel_ena;
   output logic [(NUM*2)-1:0] demo_waveforms;
   input  wire  [95       :0] demo_data;
   input  wire                clk, rst, ena;

   // Demo counter
   output logic [$clog2(DEMO_SONG_LENGTH)-1:0] demo_addr;
   wire clk_divided;
   wire clk_divided_pulse;
   clock_divider #(.N($clog2(DEMO_CLK_DIVIDE)))
   DEMO_DIVIDER (// Outputs
                 .clk_divided (clk_divided),
                 // Inputs
                 .clk         (clk),
                 .rst         (rst),
                 .divide      (DEMO_CLK_DIVIDE));
   monostable DEMO_MONOSTABLE (// Outputs
                               .out    (clk_divided_pulse),
                               // Inputs
                               .clk    (clk),
                               .rst    (rst),
                               .button (clk_divided));
   always_ff @(posedge clk) begin
      if (rst) begin
         demo_addr <= 0;
      end
      if (clk_divided_pulse) begin
         demo_addr <= ena ? demo_addr + 1 : 0;
      end
   end

   // Output logic (it's a mess)
   logic [15:0] voice0, voice1, voice2,
                voice3, voice4, voice5;
   logic [11:0] voice0_pitch, voice1_pitch, voice2_pitch,
                voice3_pitch, voice4_pitch, voice5_pitch;
   logic [3:0]  voice0_vol, voice1_vol, voice2_vol,
                voice3_vol, voice4_vol, voice5_vol;
   logic [1:0]  voice0_wave, voice1_wave, voice2_wave,
                voice3_wave, voice4_wave, voice5_wave;

   always_comb begin
      voice0           = demo_data[15:00];
      voice1           = demo_data[31:16];
      voice2           = demo_data[47:32];
      voice3           = demo_data[63:48];
      voice4           = demo_data[79:64];
      voice5           = demo_data[95:80];

      voice0_pitch     = voice0[15:4];
      voice1_pitch     = voice1[15:4];
      voice2_pitch     = voice2[15:4];
      voice3_pitch     = voice3[15:4];
      voice4_pitch     = voice4[15:4];
      voice5_pitch     = voice5[15:4];

      case(voice0[3:2])
        0: voice0_vol  = 4'b0000;
        1: voice0_vol  = 4'b0001;
        2: voice0_vol  = 4'b0011;
        3: voice0_vol  = 4'b1111;
      endcase
      case(voice1[3:2])
        0: voice1_vol  = 4'b0000;
        1: voice1_vol  = 4'b0001;
        2: voice1_vol  = 4'b0011;
        3: voice1_vol  = 4'b1111;
      endcase
      case(voice2[3:2])
        0: voice2_vol  = 4'b0000;
        1: voice2_vol  = 4'b0001;
        2: voice2_vol  = 4'b0011;
        3: voice2_vol  = 4'b1111;
      endcase
      case(voice3[3:2])
        0: voice3_vol  = 4'b0000;
        1: voice3_vol  = 4'b0001;
        2: voice3_vol  = 4'b0011;
        3: voice3_vol  = 4'b1111;
      endcase
      case(voice4[3:2])
        0: voice4_vol  = 4'b0000;
        1: voice4_vol  = 4'b0001;
        2: voice4_vol  = 4'b0011;
        3: voice4_vol  = 4'b1111;
      endcase
      case(voice5[3:2])
        0: voice5_vol  = 4'b0000;
        1: voice5_vol  = 4'b0001;
        2: voice5_vol  = 4'b0011;
        3: voice5_vol  = 4'b1111;
      endcase

      voice0_wave      = voice0[1:0];
      voice1_wave      = voice1[1:0];
      voice2_wave      = voice2[1:0];
      voice3_wave      = voice3[1:0];
      voice4_wave      = voice4[1:0];
      voice5_wave      = voice5[1:0];

      // Outputs
      demo_pitches     = {12'b0,
                          {4{voice0_pitch}},
                          {4{voice1_pitch}},
                          {4{voice2_pitch}},
                          {4{voice3_pitch}},
                          {4{voice4_pitch}},
                          {4{voice5_pitch}}};
      demo_waveforms   = {2'b0,
                          {4{voice0_wave}},
                          {4{voice1_wave}},
                          {4{voice2_wave}},
                          {4{voice3_wave}},
                          {4{voice4_wave}},
                          {4{voice5_wave}}};
      demo_channel_ena = {1'b0,
                          voice0_vol,
                          voice1_vol,
                          voice2_vol,
                          voice3_vol,
                          voice4_vol,
                          voice5_vol};

   end

endmodule
