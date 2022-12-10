`timescale 1ns / 1ps

module test_main;
   // Outputs
   wire pwm_out;

   // Inputs
   logic       clk, rst;
   logic [1:0] buttons;

   // Base it off the real world version
   parameter CLOCK_FREQ  = 12_000_000; // 12MHz
   parameter NOTE_CYCLES =    200_000;


   main UUT(/*AUTOINST*/
            // Outputs
            .pwm_out                    (pwm_out),
            // Inputs
            .clk                        (clk),
            .rst                        (rst),
            .buttons                    (buttons[1:0]));

   always #2 clk = ~clk; // Set how many time units clocking takes.

   initial begin
      $dumpfile("main.fst");
      $dumpvars(0, UUT);

      // Set inputs off
      buttons = 2'b00;

      // Reset the clock divider
      clk = 0;
      rst = 1;
      repeat (2) @(negedge clk);

      // Run a few cycles and then reset again to ensure pwm gets reset
      // properly (requires a valid signal on `audio` to reset in simulation)
      rst = 0;
      repeat (4) @(negedge clk);
      rst = 1;
      repeat (2) @(negedge clk); // Reset should finally be done

      // Test with 1 pitch.
      rst     = 0;
      buttons = 2'b01;
      repeat (NOTE_CYCLES) @(posedge clk);

      // Test with other pitch
      buttons = 2'b10;
      repeat (NOTE_CYCLES) @(posedge clk);

      // Test with both pitches
      buttons = 2'b11;
      repeat (NOTE_CYCLES) @(posedge clk);

      // Test with no pitches
      buttons = 2'b00;
      repeat (NOTE_CYCLES) @(posedge clk);

      $finish;
   end

endmodule
