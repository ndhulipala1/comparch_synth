`default_nettype none
`timescale 1ns / 1ps

module get_waveform(clk, rst, ena, waveform_button, waveform_out);

input wire clk, rst, ena;
input wire waveform_button;
output logic [1:0] waveform_out;

// Monostable so that we don't change states every clock cycle
// we hold button down
logic waveform_db_and_mono;
monostable MONO (.clk(clk), .rst(rst), .button(waveform_button), .out(waveform_db_and_mono));

// FSM: determine the type of waveform
enum logic [1:0] {
    S_SQUARE   = 0,
    S_TRIANGLE = 1,
    S_SAWTOOTH = 2
    // S_SINE,
} state;

always_ff @(posedge clk) begin : waveform_fsm
    if (rst) begin
        state <= S_SQUARE;
    end else if (ena) begin
       if (waveform_db_and_mono) begin
          case (state)
            S_SQUARE   : state <= S_TRIANGLE;
            S_TRIANGLE : state <= S_SAWTOOTH;
            S_SAWTOOTH : state <= S_SQUARE;
            default    : state <= S_SQUARE;
          endcase
       end
    end
end

always_comb begin : state_defs
   case (state)
     S_SQUARE   : waveform_out = 2'b00;
     S_TRIANGLE : waveform_out = 2'b01;
     S_SAWTOOTH : waveform_out = 2'b10;
     // S_SINE: waveform_out = 2'b10;
     default    : waveform_out = 2'b00;
   endcase
end

endmodule
