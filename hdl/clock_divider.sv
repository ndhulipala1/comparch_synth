`timescale 1ns / 1ps
/*
 Devices frequency of input clk by 2*(divide+1).
 (freq clk_divided) = (freq clk)/(2*(divide+1))

 Examples:
 Input | Divide | Output
 ------+--------+-------
  1kHz |      0 |  500Hz
  1kHz |      1 |  250Hz
  1kHz |      2 |  167Hz
  1kHz |      4 |  100Hz
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
         /*AUTORESET*/
         // Beginning of autoreset for uninitialized flops
         clk_divided <= 1'h0;
         counter <= {N{1'b0}};
         // End of automatics
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
