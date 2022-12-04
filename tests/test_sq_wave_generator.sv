`timescale 1ns / 1ps

module test_sq_wave_generator;

parameter CLK_HZ = 40_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter PERIOD_US = 10; 
parameter CLK_TICKS = CLK_HZ*PERIOD_US/1_000_000;

logic clk, rst, ena;
logic [$clog2(CLK_TICKS)-1:0] pitch_ticks;
wire out;

square_wave_generator #(.N($clog2(CLK_TICKS))) UUT(
  .clk(clk), .rst(rst), .ena(ena), .pitch_ticks(pitch_ticks), .out(out)
);

always #5 clk = ~clk;

initial begin
  $dumpfile("sq_wave_generator.fst");
  $dumpvars(0, UUT);

  rst = 1;
  ena = 1;
  clk = 0;
  pitch_ticks = CLK_TICKS;
  $display("Output a pulse ever %d (%d) ticks...", pitch_ticks, CLK_TICKS);
  
  repeat (2) @(negedge clk);
  rst = 0;

  repeat (4*CLK_TICKS) @(posedge clk);
  
  @(negedge clk);
  ena = 0;
  repeat (2*CLK_TICKS) @(posedge clk);
  $finish;
end

endmodule
