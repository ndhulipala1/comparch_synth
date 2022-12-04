`timescale 1ns / 1ps

module test_clock_divider_generator;
   logic clk, rst;
   logic [3:0] divide;
   wire  clk_divided;

   parameter CYCLES = 32;
   
   clock_divider #(.N(4)) UUT(.clk(clk), 
                              .rst(rst), 
                              .divide(divide), 
                              .clk_divided(clk_divided));

   always #5 clk = ~clk;

   initial begin
      $dumpfile("clock_divider.fst");
      $dumpvars(0, UUT);
      rst = 1;
      clk = 0;
      divide = 0;

      repeat (2) @(negedge clk);
      rst = 0;

      repeat (CYCLES) @(posedge clk);
      
      @(negedge clk);

      divide = 1;
      repeat (CYCLES) @(posedge clk);

      divide = 2;
      repeat (CYCLES) @(posedge clk);

      divide = 3;
      repeat (CYCLES) @(posedge clk);

      divide = 4;
      repeat (CYCLES) @(posedge clk);
      
      $finish;
   end

endmodule
