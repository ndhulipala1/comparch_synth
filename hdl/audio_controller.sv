`include "i2c_types.sv"

`default_nettype none
`timescale 1ns / 100ps

`define DAC_ADDR (7'h62) // TODO: define address for where DAC is in a separate file

module audio_controller(clk, rst, ena, scl, sda, channel1, channel2, out);

parameter CLK_HZ = 400_000;
parameter I2C_CLK_HZ = 100_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2C_CLK_HZ/2;  // Divide by two necessary since we toggle the signal

parameter DEFAULT_THRESHOLD = 256;
parameter N_RD_BYTES = 16;

// Module I/O and parameters
input wire clk, rst, ena;
output wire scl;
inout wire sda;
input wire [10:0] channel1, channel2;
output wire [11:0] out;

// TODO: implement channel adding

wire i_ready;
logic i_valid;
logic [11:0] i_data;
logic o_ready;
wire o_valid;
wire [11:0] o_data;

i2c_controller #(.CLK_HZ(CLK_HZ), .I2C_CLK_HZ(I2C_CLK_HZ)) I2C0 (
  .clk(clk), .rst(rst), 
  .scl(scl), .sda(sda),
  .mode(i2c_mode), .i_ready(i_ready), .i_valid(i_valid), .i_addr(`DAC_ADDR), .i_data(i_data),
  .o_ready(o_ready), .o_valid(o_valid), .o_data(o_data)
);

// Main FSM
enum logic [3:0] {
  S_IDLE = 0,
  S_INIT = 1,
  S_WAIT_FOR_I2C_WR = 2,
  S_WAIT_FOR_I2C_RD = 3,
  S_SET_SOUND = 4,
//   S_SET_THRESHOLD_DATA = 5,
//   S_GET_REG_REG = 6,
//   S_GET_REG_DATA = 7,
//   S_GET_REG_DONE = 8,
  S_DONE = 5,
  S_ERROR
} state, state_after_wait;

logic [$clog2(N_RD_BYTES):0] bytes_counter;

always_ff @(posedge clk) begin
  if(rst) begin
    state <= S_INIT;
    state_after_wait <= S_IDLE;
    bytes_counter <= 0;
    // TODO: buffers?
  end else begin
    case(state)
      // FSM should always be set to send the sound over when
      // DAC is ready for it
      S_IDLE : begin
        if(i_ready & ena)
        //   active_register <= TD_STATUS;
          state <= S_SET_SOUND;
      end
      S_INIT : begin
        state <= S_SET_SOUND;
      end
      // once sound is sent over I2C, set state to IDLE
      S_SET_SOUND: begin
        state <= S_WAIT_FOR_I2C_WR;
        state_after_wait <= S_IDLE;
      end
      S_WAIT_FOR_I2C_WR : begin
        if(i_ready) state <= state_after_wait;
      end
      // No need for reading, since we will take output of synth directly from 
      // Vout pin of the DAC
      S_WAIT_FOR_I2C_RD : begin
        if(i_ready & o_valid) state <= state_after_wait;
      end
    endcase
  end
end

always_comb case(state)
  S_IDLE: i_valid = 0;
  S_INIT: i_valid = 0;
  S_RD_DATA: i_valid = 1;
  S_WAIT_FOR_I2C_WR: i_valid = 0;
  S_WAIT_FOR_I2C_RD: i_valid = 0;
  S_SET_SOUND: i_valid = 1;
//   S_SET_THRESHOLD_DATA: i_valid = 1;
//   S_GET_REG_REG: i_valid = 1;
//   S_GET_REG_DATA: i_valid = 1;
  default: i_valid = 0;
endcase 

always_comb begin
  // always in write mode; no need to read for MVP
  i2c_mode = WRITE_8BIT_REGISTER;
end


always_comb case(state)
  S_SET_SOUND: i_data = out;
//   S_SET_THRESHOLD_DATA: i_data = `FT6206_DEFAULT_THRESHOLD;
//   S_GET_REG_REG: i_data = active_register;
  default: i_data = 0;
endcase



endmodule