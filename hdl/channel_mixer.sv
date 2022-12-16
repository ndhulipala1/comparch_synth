`default_nettype none
`timescale 1ns/10ps

/*
 Instantiates N channels and adds them together to form a 12 bit audio output.
*/

module channel_mixer (/*AUTOARG*/
   // Outputs
   audio,
   // Inputs
   channel_ena, clk, pitches, rst, waveforms
   );

   parameter NUM = 4;  // Number of channels to use
   parameter M   = 6;  // Size of period in bits
   parameter C   = 12; // Size of pitch input in bits
   parameter N   =  $clog2(4095/NUM); // Channel output size in bits


   output logic [11:0] audio;

   input wire [(NUM*C)-1:0] pitches;     // Bus of pitch inputs
   input wire [    NUM-1:0] channel_ena; // Bus of enables
   input wire [(NUM*2)-1:0] waveforms;   // Bus of waveform selects
   input wire               clk, rst;

   // Instantiate N channels
   wire [(NUM*N)-1:0] channels; // Outputs from channel
   generate
      genvar i;
      for (i=0; i<NUM; i = i+1) begin
         channel #(.M(M), .N(N), .C(C))
         CHANNEL (// Outputs
                  .out      (channels    [(N*(i+1))-1:(N*i)]),
                  // Inputs
                  .pitch    (pitches     [(C*(i+1))-1:(C*i)]),
                  .waveform (waveforms   [(2*(i+1))-1:(2*i)]),
                  .ena      (channel_ena [i]),
                  .clk      (clk),
                  .rst      (rst));
      end
   endgenerate

   // Sum up the waveforms to an audio signal
   wave_adder #(.NUM(NUM), .N(N)) WAVE_ADDER (// Outputs
                                              .audio    (audio),
                                              // Inputs
                                              .channels (channels));

endmodule
