`timescale 1ns / 1ps
/*
 Devices frequency of input clk by 2*(divide+1).
 (freq   clk_divided) = (freq   clk) / (2*(divide+1))
 (period clk_divided) = (period clk) * (2*(divide+1))

 Examples:
     Input | Divide | Output
 ----------+--------+-------
  1kHz/1mS |      0 |  500Hz/2mS
  1kHz/1mS |      1 |  250Hz/4mS
  1kHz/1mS |      2 |  167Hz/6mS
  1kHz/1mS |      4 |  100Hz/10mS
*/

module clock_divider(/*AUTOARG*/
   // Outputs
   clk_divided,
   // Inputs
   clk, divide, rst
   );
   parameter N = 8;

   input  wire  clk, rst;
   output logic clk_divided;
   input  wire  [N-1:0] divide;

   logic [N-1:0] counter;

   always_ff @(posedge clk) begin
      if (rst) begin
         clk_divided <= 0;
         counter     <= 0;
      end
      else begin
         if (counter >= divide) begin // Ignore last bit
            clk_divided <= ~clk_divided;
            counter     <= 0;
         end
         else begin
            counter <= counter + 1;
         end
      end
   end
endmodule
