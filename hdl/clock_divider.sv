`timescale 1ns / 1ps
/*
 Devices frequency of input clk by divide.
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
         // End of automatics
      end
      else begin
         if (divide <= 2) begin // If divide is 2 or less, divide by 2
            // Keep freq the same
            clk_divided <= ~clk_divided;
            counter     <= 0;
         end
         else begin // 2 or greater
            if (counter >= divide[N-1:1]) begin // Ignore last bit
               clk_divided <= ~clk_divided;
               counter     <= 0;
            end
            else begin
               counter <= counter + 1;
            end
         end
      end
   end
endmodule
