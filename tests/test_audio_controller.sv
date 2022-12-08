`timescale 1ns / 1ps

module test_audio_controller;
   // Base it off the real world version
   parameter CLK_HZ = 40_000;
   parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
   parameter MAX_CYCLES = 100_000;

   // Outputs
   wire [11:0] out;
//    wire scl;
//    wire sda;

   // Inputs
   logic clk, ena, rst;
   wire scl;
   wire sda;
   logic [10:0] channel1, channel2;

   audio_controller UUT(/*AUTOINST*/
               // Outputs
               .out                     (out[11:0]),
               // Inputs
               .clk                     (clk),
               .ena                     (ena),
               .rst                     (rst),
               .scl                     (scl),
               .sda                     (sda),
               .channel1                (channel1[10:0]),
               .channel2                (channel2[10:0]));

   audio_model MODEL(.rst(rst), .scl(scl), .sda(sda));

   always #5 clk = ~clk;

   initial begin
      $dumpfile("audio_controller.fst");
      $dumpvars(0, UUT);
      $dumpvars(0, MODEL);

      // Reset the clock divider
      clk = 0;
      ena = 1;
      rst = 1;
      repeat (2) @(negedge clk);

      rst = 0;
      channel1 = 11'b0;
      channel2 = 11'b0;

      repeat (100_000) @(posedge clk) begin
        channel1 = channel1 + 1;
        channel2 = channel2 + 4;
      end

      ena = 0;
      repeat (100_000) @(negedge clk);

      $finish;
   end

   // Put a timeout to make sure the simulation doesn't run forever.
   initial begin
      repeat (MAX_CYCLES) @(posedge clk);
      $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
      $finish;
   end

endmodule


// `timescale 1ns/1ps

// `define SIMULATION
// `define VERBOSE

// `include "ft6206_defines.sv"
// `include "i2c_types.sv"

// module test_ft6206_controller();
// parameter CLK_HZ = 12_000_000;
// parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
// parameter MAX_CYCLES = 1_000_000;

// //Module I/O and parameters
// logic clk, rst, ena;
// wire scl;
// wire sda;
// wire [7:0] weight;
// wire [3:0] area;
// touch_t touch0, touch1;


// ft6206_controller UUT (clk, rst, ena, scl, sda, touch0, touch1);

// ft6206_model MODEL (rst, scl, sda);


// // Run our main clock.
// always #(CLK_PERIOD_NS/2) clk = ~clk;

// initial begin
//   $dumpfile("ft6206_controller.fst");
//   $dumpvars(0, UUT);
//   $dumpvars(0, MODEL);
  
//   clk = 0;
//   rst = 1;
//   ena = 1;

//   repeat (2) @(negedge clk);

//   rst = 0;

//   @(posedge touch0.valid);
//   print_touch(touch0);

//   repeat (100) @(negedge clk);
//   ena = 0;
//   repeat (100) @(negedge clk);

//   $finish;  

// end



// // Put a timeout to make sure the simulation doesn't run forever.
// initial begin
//   repeat (MAX_CYCLES) @(posedge clk);
//   $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
//   $finish;
// end

// endmodule

