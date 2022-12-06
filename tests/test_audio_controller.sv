`timescale 1ns / 1ps

module test_audio_controller;
   // Base it off the real world version
   parameter CLK_HZ = 40_000;
   parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
   parameter PERIOD_US = 10;
   parameter I2C_CLK_HZ = 100_000; // Must be <= 400kHz
   parameter CLK_TICKS = CLK_HZ*PERIOD_US/1_000_000;
   parameter DIVIDER_COUNT = CLK_HZ/I2C_CLK_HZ/2;  // Divide by two necessary since we toggle the signal

   // Outputs
   wire [11:0] out;
//    wire scl;
//    wire sda;

   // Inputs
   logic clk, ena, rst;
   logic [10:0] channel1, channel2;

   audio_controller UUT(/*AUTOINST*/
               // Outputs
               .out                     (out[11:0]),
               // Inputs
               .clk                     (clk),
               .ena                     (ena),
               .rst                     (rst),
               .channel1                (channel1[10:0]),
               .channel2                (channel2[10:0]));

   always #5 clk = ~clk;

   initial begin
      $dumpfile("audio_controller.fst");
      $dumpvars(0, UUT);

      // Reset the clock divider
      clk = 0;
      ena = 0;
      rst = 1;
      repeat (2) @(negedge clk);

      // TODO: implement test procedure for testing audio_controller

      $finish;
   end

endmodule
