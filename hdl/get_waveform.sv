`default_nettype none
`timescale 1ns / 1ps

module get_waveform(clk, rst, ena, waveform_button, waveform_out);

input wire clk, rst, ena;
input wire waveform_button;
output logic [1:0] waveform_out;

// Debounce the button first to get a consistent signal
wire waveform_db;
debouncer DEBOUNCER (.clk(clk), .rst(rst), .bouncy_in(waveform_button), .debounced_out(waveform_db));

// Monostable so that we don't change states every clock cycle
// we hold button down
logic waveform_db_and_mono;
monostable MONO (.clk(clk), .rst(rst), .button(waveform_db), .out(waveform_db_and_mono));

// FSM: determine the type of waveform
enum logic [1:0] {
    S_SQUARE,
    S_TRIANGLE,
    S_SINE,
    S_SAWTOOTH
} state;
always_ff @(posedge clk) begin : waveform_fsm
    if (rst) begin
        state <= S_SQUARE;
    end else begin
        case (state)
        S_SQUARE: if (waveform_db_and_mono) state <= S_TRIANGLE;
        S_TRIANGLE: if (waveform_db_and_mono) state <= S_SINE;
        S_SINE: if (waveform_db_and_mono) state <= S_SAWTOOTH;
        S_SAWTOOTH: if (waveform_db_and_mono) state <= S_SQUARE;
        endcase
    end
end
always_comb begin : state_defs
    case (state)
        S_SQUARE: waveform_out = 2'b00;
        S_TRIANGLE: waveform_out = 2'b01;
        S_SINE: waveform_out = 2'b10;
        S_SAWTOOTH: waveform_out = 2'b11;
    endcase
end

endmodule