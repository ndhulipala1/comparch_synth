`timescale 1ns / 1ps

module test_wave_adder;
   // Outputs
   wire [11:0] out;

   // Inputs
   logic clk, ena, rst;
   logic [10:0] channel1, channel2;

   wave_adder UUT(/*AUTOINST*/
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
      $dumpfile("wave_adder.fst");
      $dumpvars(0, UUT);

      // Reset the clock divider
      clk = 0;
      ena = 0;
      rst = 1;
      repeat (2) @(negedge clk);

      channel1 = 11'b0;
      channel2 = 11'b0;

      repeat (100_000) @(posedge clk) begin
        channel1 = channel1 + 1;
        channel2 = channel2 + 4;
      end

      $finish;
   end

endmodule
